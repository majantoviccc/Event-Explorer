defmodule EventExplorerWeb.EventLive.Show do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events

  def mount(%{"id" => id}, _session, socket) do
    id = String.to_integer(id)

    case Events.get_event(id) do
      {:ok, event} ->
        related = Events.related_events(event)

        {:ok,
         socket
         |> assign(:event, event)
         |> assign(:related, related)}

      {:error, :not_found} ->
        {:ok,
         socket
         |> assign(:event, nil)
         |> assign(:related, [])}
    end
  end

  def handle_event("delete", _, socket) do
    case socket.assigns.event do
      nil ->
        {:noreply, socket}

      event ->
        case Events.delete_event(event) do
          {:ok, _} ->
            {:noreply, push_navigate(socket, to: "/events")}

          _ ->
            {:noreply, socket}
        end
    end
  end

  def render(assigns) do
    ~H"""
    <%= if @event do %>

    <div id="top" class="bg-black text-white min-h-screen">

      <section class="flex justify-center items-center pt-32 pb-20 px-4">
        <div class="bg-[#111] rounded-2xl p-8 w-[420px] md:w-[480px] shadow-2xl border border-[#FF1051]/30">

          <img src={@event.image || "/images/placeholder.jpg"} class="w-full h-[240px] object-cover rounded-xl mb-4"/>

          <h2 class="text-2xl font-bold mb-3">
            <%= @event.title %>
          </h2>

          <div class="flex gap-2 flex-wrap mb-3">
            <%= for cat <- @event.categories do %>
              <span class="bg-[#FF1051] text-xs px-2 py-1 rounded">
                <%= cat.name %>
              </span>
            <% end %>
          </div>

          <p class="text-sm text-gray-400">
            Location: <%= @event.venue.name %>, <%= @event.venue.city.name %>
          </p>

          <p class="text-sm text-gray-400">
            Date: <%= @event.date %>
          </p>

          <p class="text-sm text-gray-400">
            Time: <%= @event.time %>
          </p>

          <p class="text-sm text-gray-400 mb-2">
            Price: $<%= @event.price %>
          </p>

          <p class="text-sm text-gray-300 mt-3">
            <%= @event.description %>
          </p>

          <div class="flex gap-3 mt-6">

            <.link
              navigate={~p"/events/#{@event.id}/edit"}
              class="flex-1 text-center bg-gray-700 py-3 rounded hover:bg-gray-600"
            >
              Edit
            </.link>

            <button
              phx-click="delete"
              class="flex-1 bg-[#FF1051] py-3 rounded hover:bg-[#e00e47]"
            >
              Delete
            </button>

          </div>

        </div>
      </section>

      <section class="px-6 pb-12">
        <h3 class="text-xl font-semibold mb-4">Related Events</h3>

        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
          <%= for event <- @related do %>
            <.link navigate={~p"/events/#{event.id}"} class="block">
              <div class="bg-[#111] rounded-xl p-3 hover:scale-105 transition">

                <img src={event.image || "/images/placeholder.jpg"} class="h-[120px] w-full object-cover rounded-md"/>

                <h4 class="mt-2 text-sm font-semibold">
                  <%= event.title %>
                </h4>

                <p class="text-xs text-gray-400">
                  <%= event.date %>
                </p>

                <span class="bg-[#FF1051] text-xs px-2 py-1 rounded mt-1 inline-block">
                  <%= event.venue.city.name %>
                </span>

              </div>
            </.link>
          <% end %>
        </div>
      </section>

    </div>

    <% else %>

    <div class="flex items-center justify-center min-h-screen bg-black">
      <div class="bg-[#2a0d14] border border-[#FF1051] rounded-xl p-8 text-center shadow-2xl">

        <p class="text-[#FF1051] text-lg font-semibold mb-2">
          Error
        </p>

        <p class="text-white text-2xl font-bold mb-3">
          Event not found
        </p>

        <p class="text-gray-300 text-sm mb-6">
          This event is not available at the moment or doesn't exist.
        </p>

        <.link
          navigate="/events"
          class="bg-[#FF1051] px-6 py-2 rounded hover:bg-[#e00e47]"
        >
          Back to Events
        </.link>

      </div>
    </div>

    <% end %>
    """
  end
end
