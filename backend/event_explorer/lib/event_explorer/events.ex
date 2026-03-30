defmodule EventExplorer.Events do
  import Ecto.Query

  alias EventExplorer.Repo
  alias EventExplorer.Events.Event
  alias EventExplorer.Categories.Category
  alias EventExplorer.Cities.City
  alias EventExplorer.Venues.Venue

  def list_events(params \\ %{}) do
    Event
    |> filter_city(params)
    |> filter_category(params)
    |> search_title(params)
    |> sort_by_date(params)
    |> filter_featured(params)
    |> Repo.all()
    |> Repo.preload([:categories, venue: :city])
  end

  defp filter_city(query, %{"city" => ""}), do: query

  defp filter_city(query, %{"city" => city}) do
    from e in query,
      join: v in assoc(e, :venue),
      join: c in assoc(v, :city),
      where: c.name == ^city
  end

  defp filter_city(query, _), do: query

  defp filter_category(query, %{"category" => ""}), do: query

  defp filter_category(query, %{"category" => categories}) do
    categories = List.wrap(categories)

    from e in query,
      join: c in assoc(e, :categories),
      where: c.name in ^categories,
      distinct: e.id
  end

  defp filter_category(query, _), do: query
  defp search_title(query, %{"search" => ""}), do: query

  defp search_title(query, %{"search" => term}) do
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

  def get_event(id) do
    Event
    |> Repo.get(id)
    |> Repo.preload([:categories, venue: :city])
  end

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> put_categories(attrs)
    |> Repo.insert()
    |> case do
      {:ok, event} -> {:ok, Repo.preload(event, [:categories, venue: :city])}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_event(event, attrs) do
    event
    |> Event.changeset(attrs)
    |> put_categories(attrs)
    |> Repo.update()
    |> case do
      {:ok, event} -> {:ok, Repo.preload(event, [:categories, venue: :city])}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_event(event), do: Repo.delete(event)

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

  def change_event(event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  def list_categories do
    Repo.all(Category)
  end

  def list_cities do
    Repo.all(City)
  end

  def list_venues do
    Repo.all(Venue)
  end
end
