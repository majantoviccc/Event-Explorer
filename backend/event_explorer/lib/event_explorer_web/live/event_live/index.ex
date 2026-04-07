defmodule EventExplorerWeb.EventLive.Index do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events
  alias EventExplorer.Venues

  @categories [
    "Technology", "Business", "Art", "Film",
    "Music", "Wellness", "Lifestyle", "Food"
  ]

  def mount(_params, _session, socket) do
    params = %{
      "city" => "",
      "category" => [],
      "search" => "",
      "sort" => "asc",
      "featured" => "false"
    }

    cities =
      Venues.list_venues()
      |> Enum.map(& &1.city)
      |> Enum.uniq_by(& &1.id)
      |> Enum.sort_by(& &1.name)

    {:ok,
     socket
     |> assign(:params, params)
     |> assign(:events, Events.list_events(params))
     |> assign(:cities, cities)
     |> assign(:categories, @categories)}
  end

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.update("category", [], fn v -> List.wrap(v) end)
      |> Map.put_new("featured", "false")

    {:noreply,
     socket
     |> assign(:params, params)
     |> assign(:events, Events.list_events(params))}
  end

  def handle_event("clear_filters", _, socket) do
    params = %{
      "city" => "",
      "category" => [],
      "search" => "",
      "sort" => "asc",
      "featured" => "false"
    }

    {:noreply,
     socket
     |> assign(:params, params)
     |> assign(:events, Events.list_events(params))}
  end

  def render(assigns) do
    ~H"""
    <div id="top" class="bg-black text-white min-h-screen">


      <section class="relative h-[350px] flex items-center justify-center text-center overflow-hidden">
        <img src="/images/hero.jpg" class="absolute w-full h-full object-cover object-[center_30%]"/>
        <div class="absolute inset-0 bg-black/70"></div>

        <h1 class="text-4xl font-bold z-10">
          Explore <span class="text-[#FF1051]">Events</span>
        </h1>
      </section>


      <section class="flex justify-center mt-10 px-4">
        <form phx-change="filter" class="bg-[#111] p-6 rounded-xl w-full max-w-md space-y-4 shadow-lg">

          <h2 class="text-center font-semibold text-[#FF1051]">Filters Panel</h2>

          <input
            type="text"
            name="search"
            value={@params["search"]}
            placeholder="Search..."
            class="w-full p-2 bg-black border border-gray-600 rounded text-white"
          />

          <select
            name="city"
            class="w-full p-2 bg-black border border-gray-600 rounded text-white"
          >
            <option value="">All Cities</option>
            <%= for city <- @cities do %>
              <option value={city.name} selected={@params["city"] == city.name}>
                <%= city.name %>
              </option>
            <% end %>
          </select>

          <div>
            <p class="text-xs text-gray-400 mb-2">Category</p>

            <div class="grid grid-cols-2 gap-2 text-sm">
              <%= for cat <- @categories do %>
                <label class="flex items-center gap-2 bg-gray-800 px-2 py-1 rounded cursor-pointer">
                  <input
                    type="checkbox"
                    name="category[]"
                    value={cat}
                    checked={cat in (@params["category"] || [])}
                  />
                  <%= cat %>
                </label>
              <% end %>
            </div>
          </div>

          <div>
            <label class="text-xs text-gray-400">Sort</label>
            <select name="sort" class="w-full mt-1 p-2 bg-black border border-gray-600 rounded text-white">
              <option value="asc" selected={@params["sort"] == "asc"}>Upcoming</option>
              <option value="desc" selected={@params["sort"] == "desc"}>Latest</option>
            </select>
          </div>

          <label class="flex items-center gap-2 text-sm">
            <input type="checkbox" name="featured" value="true" checked={@params["featured"] == "true"}/>
            Featured Only
          </label>

          <button
            type="button"
            phx-click="clear_filters"
            class="w-full bg-[#FF1051] py-2 rounded hover:bg-[#e00e47]"
          >
            Clear Filters
          </button>

        </form>
      </section>


      <div class="flex justify-center mt-6">
        <.link
          navigate={~p"/events/new"}
          class="bg-[#FF1051] px-6 py-3 rounded-lg font-semibold hover:bg-[#e00e47] transition"
        >
          + Create Event
        </.link>
      </div>


      <section class="px-6 py-10 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
        <%= for event <- @events do %>
          <.event_card event={event} />
        <% end %>
      </section>

    </div>
    """
  end

  def event_card(assigns) do
    ~H"""
    <.link navigate={~p"/events/#{@event.id}"} class="block">
      <div class="bg-[#111] rounded-xl overflow-hidden p-3 hover:scale-105 transition">

        <img src={@event.image} class="h-[140px] w-full object-cover rounded-md"/>

        <h3 class="mt-2 text-sm font-semibold"><%= @event.title %></h3>

        <p class="text-xs text-gray-400">
          <%= @event.date %> - <%= @event.time %>
        </p>

        <div class="mt-2 flex justify-between items-center">
          <span class="bg-[#FF1051] px-2 py-1 text-xs rounded">
            <%= @event.venue.city.name %>
          </span>
          <span class="text-sm font-bold">$<%= @event.price %></span>
        </div>

      </div>
    </.link>
    """
  end
end
