defmodule EventExplorerWeb.EventLive.Form do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events
  alias EventExplorer.Events.Event

  def mount(_params, _session, socket) do
    venues = Events.list_venues()
    categories = Events.list_categories()

    {:ok,
     socket
     |> assign(:venues, venues)
     |> assign(:categories, categories)
     |> assign(:event, nil)
     |> assign(:form, nil)}
  end

  def handle_params(params, _url, socket) do
    case socket.assigns.live_action do
      :new ->
        changeset = Events.change_event(%Event{})

        {:noreply,
         socket
         |> assign(:event, nil)
         |> assign(:form, to_form(changeset))}

      :edit ->
        event = Events.get_event(params["id"])

        changeset = Events.change_event(event)

        {:noreply,
         socket
         |> assign(:event, event)
         |> assign(:form, to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <.form for={@form} phx-submit="save">
      <.input field={@form[:title]} label="Title" />

      <.input field={@form[:date]} type="date" label="Date" />
      <.input field={@form[:time]} type="time" label="Time" />

      <.input field={@form[:price]} type="number" label="Price" />

      <.input field={@form[:image]} label="Image URL" />

      <.input field={@form[:description]} type="textarea" label="Description" />

      <.input field={@form[:featured]} type="checkbox" label="Featured" />

      <.input
        field={@form[:venue_id]}
        type="select"
        label="Location"
        options={Enum.map(@venues, &{&1.name, &1.id})}
      />

      <fieldset>
        <legend>Categories</legend>

        <%= for category <- @categories do %>
          <label>
            <input
              type="checkbox"
              name="event[category_ids][]"
              value={category.id}
            />
            {category.name}
          </label>
        <% end %>
      </fieldset>

      <.button>Save</.button>
    </.form>
    """
  end

  def handle_event("save", %{"event" => params}, socket) do
    save_event(socket, socket.assigns.event, params)
  end

  defp save_event(socket, nil, params) do
    case Events.create_event(params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created")
         |> push_navigate(to: "/events")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_event(socket, event, params) do
    case Events.update_event(event, params) do
      {:ok, event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated")
         |> push_navigate(to: "/events")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
