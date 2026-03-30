defmodule EventExplorerWeb.EventLive.Form do


  use EventExplorerWeb, :live_view
  alias EventExplorer.Events
  alias EventExplorer.Events.Event


  def mount(_params, _session, socket) do

    changeset = Events.change_event(%Event{})

    {:ok, assign(socket, form: to_form(changeset))}


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

      <.input field={@form[:venue_id]} type="number" label="Venue ID" />

      <.button>Save</.button>
   </.form>
    """

  end

  def handle_event("save",%{"event" => params}, socket) do

    {:noreply, socket}

  end

end
