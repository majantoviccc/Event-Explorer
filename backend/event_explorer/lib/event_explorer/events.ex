defmodule EventExplorer.Events do
  alias EventExplorer.Events.Event
  alias EventExplorer.Repo
  import Ecto.Query

  def list_events(params \\ %{}) do
    Event
    |> filter_city(params)
    |> filter_category(params)
    |> search_title(params)
    |> sort_by_date(params)
    |> Repo.all()
    |> Repo.preload([:category, venue: :city])
  end


  defp filter_city(query, %{"city" => city}) do
    from e in query,
      join: v in assoc(e, :venue),
      join: c in assoc(v, :city),
      where: c.name == ^city
  end


  defp filter_city(query, _params) do
    query
  end


  defp filter_category(query, %{"category" => category}) do

    from e in query,
      join: c in assoc(e, :category),
      where: c.name == ^category
  end

  defp filter_category(query, _params) do
    query
  end

  defp search_title(query, %{"search" => term}) do
    from e in query,
      where: ilike(e.title, ^"%#{term}%")
  end

  defp search_title(query, _params) do
    query
  end

  defp sort_by_date(query, %{"sort" => "asc"}) do
    from e in query,
      order_by: [asc: e.date]
  end

  defp sort_by_date(query, %{"sort" => "desc"}) do
    from e in query,
      order_by: [desc: e.date]
  end

  defp sort_by_date(query, _params) do
    query
  end

  def get_event(id) do
    Event
    |> Repo.get(id)
    |> Repo.preload([:category, venue: :city])
  end

  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok,event} -> {:ok, Repo.preload(event, [:category, venue: :city])}
      {:error , changeset} -> {:error, changeset}
    end

  end

  def update_event(event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok,event} -> {:ok,Repo.preload(event, [:category, venue: :city])}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_event(event) do
    Repo.delete(event)
  end
end
