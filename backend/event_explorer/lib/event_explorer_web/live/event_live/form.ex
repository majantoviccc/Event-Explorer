defmodule EventExplorerWeb.EventLive.Form do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events
  alias EventExplorer.Events.Event

  alias EventExplorer.Categories
  alias EventExplorer.Cities
  alias EventExplorer.Venues

  def mount(_params, _session, socket) do
    venues = Venues.list_venues()
    categories = Categories.list_categories()

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
    <.form for={@form} phx-submit="save" class="event-form" multipart={true}>
      <.input field={@form[:title]} label="Title" />

      <div class="row">
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:time]} type="time" label="Time" />
        <.input field={@form[:price]} type="number" label="Price" />
      </div>

      <div class="row">
        <.input field={@form[:image]} type="file" label="Upload Image" />
        <.input
          field={@form[:venue_id]}
          type="select"
          label="Location"
          options={Enum.map(@venues, &{&1.name, &1.id})}
        />
      </div>

      <.input field={@form[:description]} type="textarea" label="Description" />

      <div class="checkbox-row">
        <.input field={@form[:featured]} type="checkbox" label="Featured" />
      </div>

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

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.live_action, event_params)
  end

  defp save_event(socket, :new, params) do
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

  defp save_event(socket, :edit, params) do
    event = socket.assigns.event

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
