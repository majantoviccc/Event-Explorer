defmodule EventExplorerWeb.Api.EventJSON do
  @moduledoc """
  JSON views for event API responses.
  """

  @doc "Renders a list of events."
  @spec index(map()) :: map()
  def index(%{events: events}) do
    %{
      events: Enum.map(events, &data/1)
    }
  end

  @doc "Renders a single event."
  @spec show(map()) :: map()
  def show(%{event: event}) do
    data(event)
  end

  @doc false
  defp data({:ok, event}), do: data(event)

  @doc false
  defp data(event) do
    %{
      id: event.id,
      title: event.title,
      date: event.date,
      time: event.time,
      city: %{
        id: event.venue.city.id,
        name: event.venue.city.name
      },
      venue: %{
        id: event.venue.id,
        name: event.venue.name
      },
      categories:
        Enum.map(event.categories, fn category ->
          %{
            id: category.id,
            name: category.name
          }
        end),
      price: format_price(event.price),
      image: event.image,
      description: event.description,
      featured: event.featured
    }
  end

  
  defp format_price(nil), do: nil
  defp format_price(price), do: Decimal.to_string(price)
end
