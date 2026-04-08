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
  <div class="min-h-screen bg-[#0f0f0f] flex items-center justify-center px-4">
    <div class="w-full max-w-xl bg-[#171717] p-6 rounded-2xl shadow-2xl border border-[#222] text-white">

      <h2 class="text-2xl mb-6 font-semibold"><%= @page_title %></h2>

      <.form for={@form} multipart phx-submit="save" phx-change="validate" class="space-y-4">

        <div>
          <label class="block text-sm text-gray-400 mb-1">Title</label>
          <.input field={@form[:title]} class="w-full bg-[#1a1a1a] border border-[#333] rounded-lg px-4 py-2 focus:border-white focus:outline-none"/>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-sm text-gray-400 mb-1">Date</label>
            <.input field={@form[:date]} type="date" class="w-full bg-[#1a1a1a] border border-[#333] rounded-lg px-4 py-2 focus:border-white focus:outline-none"/>
          </div>

          <div>
            <label class="block text-sm text-gray-400 mb-1">Time</label>
            <.input field={@form[:time]} type="time" class="w-full bg-[#1a1a1a] border border-[#333] rounded-lg px-4 py-2 focus:border-white focus:outline-none"/>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-sm text-gray-400 mb-1">Price</label>
            <.input field={@form[:price]} type="number" class="w-full bg-[#1a1a1a] border border-[#333] rounded-lg px-4 py-2 focus:border-white focus:outline-none"/>
          </div>

          <div>
            <label class="block text-sm text-gray-400 mb-1">Venue</label>
            <.input field={@form[:venue_id]} type="select" options={@venues}
              class="w-full bg-[#1a1a1a] border border-[#333] rounded-lg px-4 py-2 focus:border-white focus:outline-none"/>
          </div>
        </div>

        <div>
          <label class="block text-sm text-gray-400 mb-1">Description</label>
          <.input field={@form[:description]} class="w-full bg-[#1a1a1a] border border-[#333] rounded-lg px-4 py-2 focus:border-white focus:outline-none"/>
        </div>

        <label class="flex items-center gap-2 text-gray-300 text-sm">
          <input
            type="checkbox"
            name="event[featured]"
            value="true"
            class="accent-white"
            checked={@form.params["featured"] == "true" || @form.data.featured}
          />
          Featured
        </label>

        <div>
          <p class="text-gray-400 mb-2 text-sm">Categories</p>

          <div class="grid grid-cols-2 gap-2">
            <%= for {name, id} <- @categories do %>
              <label class="cursor-pointer">
                <input
                  type="checkbox"
                  name="event[category_ids][]"
                  value={id}
                  class="peer hidden"
                  checked={
                    id in (
                      Map.get(@form.params || %{}, "category_ids", [])
                      |> Enum.map(fn x -> if is_binary(x), do: String.to_integer(x), else: x end)
                    )
                  }
                />

                <span class="block text-center bg-[#1f1f1f] border border-[#333] rounded-lg py-2 text-sm text-gray-300 transition
                             hover:bg-[#2a2a2a] peer-checked:bg-white peer-checked:text-black peer-checked:border-white">
                  <%= name %>
                </span>
              </label>
            <% end %>
          </div>
        </div>

        <div>
          <label class="block text-sm text-gray-400 mb-2">Image</label>
          <.live_file_input
            upload={@uploads.image}
            class="text-gray-300 file:bg-zinc-800 file:border-0 file:text-white file:px-3 file:py-1 file:rounded file:cursor-pointer"
          />
        </div>

        <button class="w-full bg-white text-black py-2 rounded-lg font-semibold hover:opacity-90 transition">
          Save Event
        </button>

      </.form>
    </div>
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
