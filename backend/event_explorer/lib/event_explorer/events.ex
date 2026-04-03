defmodule EventExplorer.Events do
  @moduledoc """
  Context module responsible for managing events.
  """

  import Ecto.Query

  alias EventExplorer.Repo
  alias EventExplorer.Events.Event
  alias EventExplorer.Categories.Category
  alias EventExplorer.Uploaders.Cloudinary

  @event_preloads [:categories, venue: :city]

  @spec list_events(map()) :: list()
  def list_events(params \\ %{}) do
    Event
    |> filter_city(params)
    |> filter_category(params)
    |> search_title(params)
    |> sort_by_date(params)
    |> filter_featured(params)
    |> distinct(true)
    |> preload(^@event_preloads)
    |> Repo.all()
  end

  defp filter_city(query, %{"city" => city}) when city != "" do
    from e in query,
      join: v in assoc(e, :venue),
      join: c in assoc(v, :city),
      where: c.name == ^city
  end

  defp filter_city(query, _), do: query

  defp filter_category(query, %{"category" => categories}) do
    categories =
      categories
      |> List.wrap()
      |> Enum.reject(&(&1 == ""))

    if categories == [] do
      query
    else
      from e in query,
        join: c in assoc(e, :categories),
        where: c.name in ^categories,
        group_by: e.id,
        having: count(c.id) == ^length(categories)
    end
  end

  defp filter_category(query, _), do: query

  defp search_title(query, %{"search" => term}) when term != "" do
    from e in query,
      where: ilike(e.title, ^"%#{term}%")
  end

  defp search_title(query, _), do: query

  defp sort_by_date(query, %{"sort" => "asc"}) do
    from e in query, order_by: [asc: e.date]
  end

  defp sort_by_date(query, %{"sort" => "desc"}) do
    from e in query, order_by: [desc: e.date]
  end

  defp sort_by_date(query, _), do: query

  defp filter_featured(query, %{"featured" => "true"}) do
    from e in query,
      where: e.featured == true
  end

  defp filter_featured(query, _), do: query

  @spec get_event(integer()) :: {:ok, map()} | {:error, :not_found}
  def get_event(id) do
    case Repo.get(Event, id) do
      nil -> {:error, :not_found}
      event -> {:ok, Repo.preload(event, @event_preloads)}
    end
  end

  @spec create_event(map()) ::
          {:ok, map()} | {:error, Ecto.Changeset.t()}
  def create_event(attrs) do
    attrs =
      case Map.get(attrs, "image") do
        %Plug.Upload{path: path} ->
          IO.inspect(path, label: "FILE PATH")

          result = Cloudinary.upload_image(path)
          IO.inspect(result, label: "UPLOAD RESULT")

          case result do
            {:ok, %{url: url, public_id: public_id}} ->
              attrs
              |> Map.put("image", url)
              |> Map.put("public_id", public_id)

            {:error, _} ->
              attrs
          end

        _ ->
          attrs
      end

    %Event{}
    |> Event.changeset(attrs)
    |> put_categories(attrs)
    |> Repo.insert()
    |> case do
      {:ok, event} -> {:ok, Repo.preload(event, @event_preloads)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @spec update_event(map(), map()) ::
          {:ok, map()} | {:error, Ecto.Changeset.t()}
  def update_event(event, attrs) do
    event = Repo.preload(event, :categories)

    attrs =
      case Map.get(attrs, "image") do
        %Plug.Upload{path: path} ->
          IO.inspect(path, label: "FILE PATH")

          result = Cloudinary.upload_image(path)
          IO.inspect(result, label: "UPLOAD RESULT")

          case result do
            {:ok, %{url: url, public_id: public_id}} ->
              if event.public_id do
                Cloudinary.delete_image(event.public_id)
              end

              attrs
              |> Map.put("image", url)
              |> Map.put("public_id", public_id)

            {:error, _} ->
              attrs
          end

        _ ->
          attrs
      end

    event
    |> Event.changeset(attrs)
    |> put_categories(attrs)
    |> Repo.update()
    |> case do
      {:ok, event} -> {:ok, Repo.preload(event, @event_preloads)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @spec delete_event(map()) ::
          {:ok, map()} | {:error, Ecto.Changeset.t()}
  def delete_event(event) do
    if event.public_id do
      Cloudinary.delete_image(event.public_id)
    end

    Repo.delete(event)
  end

  defp put_categories(changeset, attrs) do
    case Map.get(attrs, "category_ids", []) do
      nil ->
        changeset

      category_ids ->
        category_ids =
          Enum.map(category_ids, &String.to_integer/1)

        categories =
          from(c in Category, where: c.id in ^category_ids)
          |> Repo.all()

        Ecto.Changeset.put_assoc(changeset, :categories, categories)
    end
  end

  @spec change_event(map(), map()) :: Ecto.Changeset.t()
  def change_event(event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  @spec related_events(map()) :: list()
  def related_events(event) do
    event = Repo.preload(event, @event_preloads)

    category_ids = Enum.map(event.categories, & &1.id)

    Event
    |> join(:inner, [e], v in assoc(e, :venue))
    |> join(:inner, [e, v], c in assoc(v, :city))
    |> join(:inner, [e, v, c], cat in assoc(e, :categories))
    |> where(
      [e, v, c, cat],
      (c.id == ^event.venue.city_id or cat.id in ^category_ids) and
        e.id != ^event.id
    )
    |> limit(5)
    |> preload(^@event_preloads)
    |> Repo.all()
  end
end
