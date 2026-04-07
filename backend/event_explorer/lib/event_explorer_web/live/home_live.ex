defmodule EventExplorerWeb.HomeLive do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events

  def mount(_params, _session, socket) do
    events = Events.list_events(%{"sort" => "asc"})
    featured = Enum.filter(events, & &1.featured)

    {:ok,
     socket
     |> assign(:events, events)
     |> assign(:featured, featured)
     |> assign(:filter, "asc")}
  end

  def handle_event("change_filter", %{"sort" => value}, socket) do
    events = Events.list_events(%{"sort" => value})

    {:noreply,
     socket
     |> assign(:events, events)
     |> assign(:filter, value)}
  end

  def render(assigns) do
    ~H"""
    <div id="top" class="bg-black text-white min-h-screen">


      <section class="relative h-[450px] flex items-center justify-center text-center overflow-hidden">
        <img src="/images/hero.jpg" class="absolute w-full h-full object-cover object-[center_30%]"/>
        <div class="absolute inset-0 bg-black/60"></div>

        <h1 class="text-4xl md:text-5xl font-bold z-10">
          Where Your <span class="text-[#FF1051]">Event</span> Dreams Come to Life!
        </h1>
      </section>


      <section class="p-6">
        <h2 class="text-2xl font-semibold mb-4">
          Discover our <span class="text-[#FF1051]">Featured Events</span>
        </h2>

        <div class="relative overflow-hidden">
          <div class="flex gap-3 overflow-x-auto snap-x snap-mandatory pb-2">

            <%= for event <- @featured do %>
              <.link navigate={~p"/events/#{event.id}"}>

                <div class="min-w-[280px] h-[180px] rounded-xl overflow-hidden snap-center relative group cursor-pointer">

                  <img
                    src={event.image}
                    class="w-full h-full object-cover group-hover:scale-110 transition duration-300"
                  />

                  <div class="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent"></div>

                  <div class="absolute bottom-2 left-2 right-2 text-xs">
                    <p class="font-semibold"><%= event.title %></p>
                    <p class="text-gray-300"><%= event.venue.city.name %></p>
                  </div>

                </div>

              </.link>
            <% end %>

          </div>

          <div class="flex justify-center mt-3 gap-2">
            <div class="w-2 h-2 bg-[#FF1051] rounded-full"></div>
            <div class="w-2 h-2 bg-gray-600 rounded-full"></div>
            <div class="w-2 h-2 bg-gray-600 rounded-full"></div>
          </div>
        </div>
      </section>

      <!-- FILTER -->
      <div class="flex justify-center mb-8">
        <form phx-change="change_filter" class="flex items-center gap-3">
          <span class="text-gray-300">Show:</span>

          <select name="sort" class="bg-black border border-gray-600 px-3 py-2 rounded focus:border-[#FF1051]">
            <option value="asc" selected={@filter == "asc"}>Upcoming</option>
            <option value="desc" selected={@filter == "desc"}>Latest</option>
          </select>
        </form>
      </div>


      <section class="px-6 pb-12 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
        <%= if @events == [] do %>
          <div class="col-span-full text-center text-gray-400 mt-10">
            No events found 👀
          </div>
        <% end %>

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
      <div class="bg-[#111] rounded-xl overflow-hidden shadow-lg p-3 hover:scale-105 hover:-translate-y-1 transition cursor-pointer">

        <img src={@event.image} class="h-[140px] w-full object-cover rounded-md"/>

        <h3 class="mt-2 font-semibold text-sm">
          <%= @event.title %>
        </h3>

        <p class="text-xs text-gray-400">
          <%= @event.date %> - <%= @event.time %>
        </p>

        <div class="mt-2 flex justify-between items-center">
          <span class="bg-[#FF1051] px-2 py-1 rounded text-xs">
            <%= @event.venue.city.name %>
          </span>

          <span class="font-bold text-sm">
            $<%= @event.price %>
          </span>
        </div>

      </div>
    </.link>
    """
  end
end
