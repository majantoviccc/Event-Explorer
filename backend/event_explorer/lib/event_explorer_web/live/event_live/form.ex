defmodule EventExplorerWeb.EventLive.Form do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events
  alias EventExplorer.Events.Event
  alias EventExplorer.Categories
  alias EventExplorer.Venues

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:venues, Venues.list_venues())
     |> assign(:categories, Categories.list_categories())
     |> assign(:event, nil)
     |> assign(:form, nil)
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1)}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    event = %Event{}

    socket
    |> assign(:page_title, "Create Event")
    |> assign(:event, event)
    |> assign(:form, to_form(Events.change_event(event)))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    case Events.get_event(id) do
      {:ok, event} ->
        socket
        |> assign(:page_title, "Edit Event")
        |> assign(:event, event)
        |> assign(:form, to_form(Events.change_event(event)))

      _ ->
        push_navigate(socket, to: "/events")
    end
  end

  def handle_event("validate", %{"event" => params}, socket) do
    changeset =
      socket.assigns.event
      |> Events.change_event(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"event" => params}, socket) do
    uploaded =
      consume_uploaded_entries(socket, :image, fn %{path: path}, _ ->
        {:ok, path}
      end)

    params =
      case uploaded do
        [path] ->
          Map.put(params, "image", %Plug.Upload{path: path})

        _ ->
          case socket.assigns.event do
            nil -> params
            event -> Map.put_new(params, "image", event.image)
          end
      end

    save_event(socket, socket.assigns.live_action, params)
  end

  defp save_event(socket, :new, params) do
    case Events.create_event(params) do
      {:ok, _event} ->
        {:noreply, push_navigate(socket, to: "/events")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_event(socket, :edit, params) do
    case Events.update_event(socket.assigns.event, params) do
      {:ok, event} ->
        {:noreply, push_navigate(socket, to: "/events/#{event.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-black px-4 py-10">

      <.form
        for={@form}
        phx-change="validate"
        phx-submit="save"
        class="w-full max-w-xl bg-[#111] p-8 rounded-2xl space-y-6 text-white shadow-xl"
      >

        <h2 class="text-2xl text-center text-[#FF1051] font-bold">
          <%= @page_title %>
        </h2>

        <.input field={@form[:title]} placeholder="Title"
          class="w-full bg-black border border-gray-700 rounded-lg px-4 py-2"/>

        <.input field={@form[:description]} type="textarea" placeholder="Description"
          class="w-full bg-black border border-gray-700 rounded-lg px-4 py-2 h-24"/>

        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:date]} type="date"
            class="bg-black border border-gray-700 rounded-lg px-4 py-2"/>
          <.input field={@form[:time]} type="time"
            class="bg-black border border-gray-700 rounded-lg px-4 py-2"/>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <.input field={@form[:price]} type="number" step="0.01" placeholder="Price"
            class="bg-black border border-gray-700 rounded-lg px-4 py-2"/>

          <.input field={@form[:venue_id]} type="select"
            options={Enum.map(@venues, &{&1.name, &1.id})}
            prompt="Location"
            class="bg-black border border-gray-700 rounded-lg px-4 py-2"/>
        </div>

        <%=
          event_category_ids =
            case @event do
              %{categories: %Ecto.Association.NotLoaded{}} -> []
              %{categories: categories} -> Enum.map(categories, & &1.id)
              _ -> []
            end

          selected_ids =
            if @form.params["category_ids"] do
              Enum.map(@form.params["category_ids"], &String.to_integer/1)
            else
              event_category_ids
            end
        %>

        <div class="flex flex-wrap gap-2">
          <%= for c <- @categories do %>
            <label class="flex items-center gap-2 px-3 py-1 rounded-full bg-[#1a1a1a] border border-gray-700 cursor-pointer">
              <input
                type="checkbox"
                name="event[category_ids][]"
                value={c.id}
                checked={c.id in selected_ids}
                class="accent-[#FF1051]"
              />
              <span class="text-sm"><%= c.name %></span>
            </label>
          <% end %>
        </div>

        <div>
          <%= if @event && @event.image do %>
            <img src={@event.image} class="w-full h-40 object-cover rounded mb-2"/>
          <% end %>

          <.live_file_input upload={@uploads.image}/>

          <%= for entry <- @uploads.image.entries do %>
            <.live_img_preview entry={entry} class="w-full h-40 object-cover mt-2 rounded"/>
          <% end %>
        </div>

        <button class="w-full bg-[#FF1051] py-3 rounded-lg font-semibold">
          Save Event
        </button>

      </.form>

    </div>
    """
  end
end
