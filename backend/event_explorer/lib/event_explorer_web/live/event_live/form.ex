defmodule EventExplorerWeb.EventLive.Form do
  use EventExplorerWeb, :live_view

  alias EventExplorer.Events
  alias EventExplorer.Events.Event
  alias EventExplorer.Categories
  alias EventExplorer.Venues

  def mount(params, _session, socket) do
    categories =
      Categories.list_categories()
      |> Enum.map(fn c -> {c.name, c.id} end)

    venues =
      Venues.list_venues()
      |> Enum.map(fn v -> {v.name, v.id} end)

    socket =
      socket
      |> assign(:categories, categories)
      |> assign(:venues, venues)
      |> apply_action(socket.assigns.live_action, params)
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), max_entries: 1)

    {:ok, socket}
  end

  defp apply_action(socket, :new, _params) do
    changeset = Events.change_event(%Event{})

    socket
    |> assign(:page_title, "New Event")
    |> assign(:event, %Event{})
    |> assign(:form, to_form(changeset))
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    {:ok, event} = Events.get_event(id)
    changeset = Events.change_event(event)

    socket
    |> assign(:page_title, "Edit Event")
    |> assign(:event, event)
    |> assign(:form, to_form(changeset))
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-xl mx-auto mt-10 text-white">
      <h2 class="text-2xl mb-6 font-bold"><%= @page_title %></h2>

      <.form for={@form} multipart phx-submit="save" phx-change="validate" class="space-y-4">

        <.input field={@form[:title]} label="Title" class="bg-gray-800 text-white" />

        <.input field={@form[:date]} type="date" label="Date" class="bg-gray-800 text-white" />

        <.input field={@form[:time]} type="time" label="Time" class="bg-gray-800 text-white" />

        <.input field={@form[:price]} type="number" label="Price" class="bg-gray-800 text-white" />

        <.input field={@form[:description]} label="Description" class="bg-gray-800 text-white" />

        <.input
          field={@form[:venue_id]}
          type="select"
          label="Venue"
          options={@venues}
          class="bg-gray-800 text-white"
        />

        <label class="flex items-center gap-2">
          <input
            type="checkbox"
            name="event[featured]"
            value="true"
            checked={@form.params["featured"] == "true" || @form.data.featured}
          />
          Featured
        </label>

        <div>
          <label class="block mb-2">Categories</label>

          <%= for {name, id} <- @categories do %>
            <label class="flex items-center gap-2">
              <input
                type="checkbox"
                name="event[category_ids][]"
                value={id}
                checked={
                  id in (
                    Map.get(@form.params || %{}, "category_ids", [])
                    |> Enum.map(fn x -> if is_binary(x), do: String.to_integer(x), else: x end)
                  )
                }
              />
              <%= name %>
            </label>
          <% end %>
        </div>

        <div>
          <label class="block mb-2">Image</label>
          <.live_file_input upload={@uploads.image} />
        </div>

        <button class="bg-white text-black px-4 py-2 rounded w-full">
          Save
        </button>

      </.form>
    </div>
    """
  end

  def handle_event("save", %{"event" => params}, socket) do
    IO.inspect(params, label: "RAW PARAMS")

    uploaded =
  consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
    dest = Path.join(System.tmp_dir!(), entry.client_name)
    File.cp!(path, dest)
    {:ok, dest}
  end)
    IO.inspect(uploaded, label: "UPLOADED PATHS")

    params =
  case uploaded do
    [path] ->
      Map.put(params, "image", %Plug.Upload{
        path: path,
        filename: Path.basename(path)
      })

    _ ->
      params
  end

    IO.inspect(params, label: "FINAL PARAMS")

    save_event(socket, socket.assigns.live_action, params)
  end

  defp save_event(socket, :new, params) do
    result = Events.create_event(params)
    IO.inspect(result, label: "CREATE RESULT")

    case result do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event created!")
         |> push_navigate(to: "/")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_event(socket, :edit, params) do
    result = Events.update_event(socket.assigns.event, params)
    IO.inspect(result, label: "UPDATE RESULT")

    case result do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Event updated!")
         |> push_navigate(to: "/")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"event" => params}, socket) do
    IO.inspect(params, label: "VALIDATE PARAMS")

    changeset =
      socket.assigns.event
      |> Events.change_event(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
