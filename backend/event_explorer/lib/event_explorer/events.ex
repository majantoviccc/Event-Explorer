defmodule EventExplorer.Events do
  @moduledoc """
  Context module responsible for managing events.

  Provides functionality for:
  - retrieving and filtering events
  - creating, updating, and deleting events
  - handling category associations
  - managing image uploads via Cloudinary
  - fetching related events
  """

  import Ecto.Query

  alias EventExplorer.Repo
  alias EventExplorer.Events.Event
  alias EventExplorer.Categories.Category
  alias EventExplorer.Uploaders.Cloudinary

  @event_preloads [:categories, venue: :city]

  @doc """
  Returns a list of events based on the provided filtering parameters.
  """
  @spec list_events(map()) :: list(Event.t())
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

  @doc false
  @spec filter_city(Ecto.Query.t(), map()) :: Ecto.Query.t()
  defp filter_city(query, %{"city" => city}) when city != "" do
    from e in query,
      join: v in assoc(e, :venue),
      join: c in assoc(v, :city),
      where: c.name == ^city
  end

  defp filter_city(query, _), do: query

  @doc false
  @spec filter_category(Ecto.Query.t(), map()) :: Ecto.Query.t()
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

  @doc false
  @spec search_title(Ecto.Query.t(), map()) :: Ecto.Query.t()
  defp search_title(query, %{"search" => term}) when term != "" do
    from e in query,
      where: ilike(e.title, ^"%#{term}%")
  end

  defp search_title(query, _), do: query

  @doc false
  @spec sort_by_date(Ecto.Query.t(), map()) :: Ecto.Query.t()
  defp sort_by_date(query, %{"sort" => "asc"}) do
    from e in query, order_by: [asc: e.date]
  end

  defp sort_by_date(query, %{"sort" => "desc"}) do
    from e in query, order_by: [desc: e.date]
  end

  defp sort_by_date(query, _), do: query

  @doc false
  @spec filter_featured(Ecto.Query.t(), map()) :: Ecto.Query.t()
  defp filter_featured(query, %{"featured" => "true"}) do
    from e in query,
      where: e.featured == true
  end

  defp filter_featured(query, _), do: query

  @doc """
  Retrieves a single event by its ID.

  Returns `{:ok, event}` if found, otherwise `{:error, :not_found}`.
  """
  @spec get_event(integer()) :: {:ok, Event.t()} | {:error, :not_found}
  def get_event(id) do
    case Repo.get(Event, id) do
      nil -> {:error, :not_found}
      event -> {:ok, Repo.preload(event, @event_preloads)}
    end
  end

  @doc """
  Creates a new event.

  Handles optional image upload to Cloudinary and stores the resulting URL and public ID.
  """
  @spec create_event(map()) ::
          {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def create_event(attrs) do
    attrs =
      case Map.get(attrs, "image") do
        %Plug.Upload{path: path} ->
          case Cloudinary.upload_image(path) do
            {:ok, %{url: url, public_id: public_id}} ->
              attrs
              |> Map.put("image", url)
              |> Map.put("public_id", public_id)

            {:error, _} ->
              Map.delete(attrs, "image")
          end

        _ ->
          attrs
      end

    %Event{}
    |> Event.changeset(attrs)
    |> put_categories(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an existing event.

  If a new image is provided, the old image is deleted from Cloudinary and replaced.
  """
  @spec update_event(Event.t(), map()) ::
          {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def update_event(event, attrs) do
    event = Repo.preload(event, :categories)

    attrs =
      case Map.get(attrs, "image") do
        %Plug.Upload{path: path} ->
          case Cloudinary.upload_image(path) do
            {:ok, %{url: url, public_id: public_id}} ->
              if event.public_id do
                Cloudinary.delete_image(event.public_id)
              end

              attrs
              |> Map.put("image", url)
              |> Map.put("public_id", public_id)

            {:error, _} ->
              Map.delete(attrs, "image")
          end

        _ ->
          attrs
      end

    event
    |> Event.changeset(attrs)
    |> put_categories(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an event and removes its associated image from Cloudinary if present.
  """
  @spec delete_event(Event.t()) ::
          {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def delete_event(event) do
    if event.public_id do
      Cloudinary.delete_image(event.public_id)
    end

    Repo.delete(event)
  end

  @doc false
  @spec put_categories(Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  defp put_categories(changeset, attrs) do
  case Map.get(attrs, "category_ids") do
    nil ->
      changeset

    category_ids ->
      category_ids =
        Enum.map(category_ids, fn
          id when is_binary(id) -> String.to_integer(id)
          id when is_integer(id) -> id
        end)

      categories =
        from(c in Category, where: c.id in ^category_ids)
        |> Repo.all()

      Ecto.Changeset.put_assoc(changeset, :categories, categories)
  end
end

  @doc """
  Returns a changeset for tracking event changes.
  """
  @spec change_event(Event.t(), map()) :: Ecto.Changeset.t()
  def change_event(event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  @doc """
  Returns a list of related events based on shared city or categories, excluding the given event.
  """
  @spec related_events(Event.t()) :: list(Event.t())
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
