defmodule EventExplorerWeb.EventLive.Show do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events

  def mount(%{"id" => id}, _session, socket) do
    event = Events.get_event(id)

    {:ok, assign(socket, event: event)}
  end

  def render(assigns) do
    ~H"""
    <div class="show-page">
      <div class="details-header">
        <a href="/events" class="back-btn">←</a>
        <span>Event Details</span>
      </div>

      <div class="event-actions">
        <.link navigate={"/events/#{@event.id}/edit"}>
          Edit
        </.link>

        <button class="delete-btn" phx-click="delete" phx-value-id={@event.id}>Delete</button>
      </div>

      <div class="event-card">
        <img src={@event.image} class="event-image" />

        <div class="event-content">
          <h1>{@event.title}</h1>

          <p class="event-meta">
            📍 {@event.venue.name}, {@event.venue.city.name}
          </p>

          <p class="event-meta">
            🕒 {@event.date} | {@event.time}
          </p>

          <div class="event-categories">
            <%= for category <- @event.categories do %>
              <span class="category-badge">
                {category.name}
              </span>
            <% end %>
          </div>
          <p class="event-description">
            Description: {@event.description}
          </p>
          <p class="event-price">
            💸 {@event.price}
          </p>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("delete", %{"id" => id}, socket) do
    event = Events.get_event(id)

    case Events.delete_event(event) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event successfully deleted")
         |> push_navigate(to: "/events")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete event")}
    end
  end
end
