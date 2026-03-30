defmodule EventExplorerWeb.EventLive.Index do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events

  def mount(_params, _session, socket) do
    events = Events.list_events(%{})
    categories = Events.list_categories()
    cities = Events.list_cities()

    {:ok,
     assign(socket,
       events: events,
       categories: categories,
       cities: cities
     )}
  end

  def handle_event("filter", params, socket) do
    events = Events.list_events(params)
    {:noreply, assign(socket, events: events)}
  end

  slot :inner_block, required: true
  slot :subtitle

  def page_header(assigns) do
    ~H"""
    <div class="header">
      <h1>{render_slot(@inner_block)}</h1>
      <p>{render_slot(@subtitle)}</p>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="page">
      <.page_header>
        Event Explorer ✨
        <:subtitle>
          Find event that match your interests 🎈
        </:subtitle>
      </.page_header>

      <div class="main-container">
        <div class="action">
          <.link navigate="/events/new">
            <button>Add Event +</button>
          </.link>
        </div>

        <form phx-change="filter">
          <div class="search">
            <input type="text" name="search" placeholder=" 🔍 Search events" />
          </div>

          <div class="filters">
            <select name="category[]">
              <option value="">🏷 All Categories</option>
              <%= for category <- @categories do %>
                <option value={category.name}>{category.name}</option>
              <% end %>
            </select>

            <select name="city">
              <option value="">📍 All Cities</option>
              <%= for city <- @cities do %>
                <option value={city.name}>{city.name}</option>
              <% end %>
            </select>

            <select name="sort">
              <option value="">↕ Sort by date</option>
              <option value="asc">Newest first</option>
              <option value="desc">Oldest first</option>
            </select>
          </div>
        </form>

        <div class="events-container">
          <%= for event <- @events do %>
            <div class="card" phx-click="go_to_event" phx-value-id={event.id}>
              <div class="card-image">
                <img src={event.image} />
              </div>

              <div class="card-content">
                <h3 class="card-title">{event.title}</h3>

                <p class="card-date">
                  🕒 {event.date} | {event.time}
                </p>

                <p class="card-city">
                  📍 {event.venue.city.name}
                </p>

                <p class="card-price">
                  💸 {event.price}
                </p>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <footer class="footer">
      <div class="footer-content">
        <h3 class="footer-logo">Event Explorer</h3>

        <p class="footer-desc">
          Discover and explore events around the world.
        </p>

        <div class="footer-links">
          <a href="#">Home</a>
          <a href="#">Explore</a>
          <a href="#">Contact</a>
        </div>

        <div class="footer-social">
          <span>🌐</span>
          <span>📸</span>
          <span>🐦</span>
        </div>

        <p class="footer-copy">
          © 2026 Event Explorer. All rights reserved.
        </p>
      </div>
    </footer>
    """
  end

  def handle_event("go_to_event", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/events/#{id}")}
  end
end
