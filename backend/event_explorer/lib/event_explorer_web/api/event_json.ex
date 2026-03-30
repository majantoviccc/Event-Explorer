defmodule EventExplorerWeb.Api.EventJSON do
  def index(%{events: events}) do
    %{
      events: for(event <- events, do: data(event))
    }
  end

  def show(%{event: event}) do
    data(event)
  end

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
      categories:   Enum.map(event.categories, fn category ->

        %{
            id: category.id,
            name: category.name
        }


      end ),

      price: event.price,
      image: event.image,
      description: event.description,
      featured: event.featured
    }
  end
end
