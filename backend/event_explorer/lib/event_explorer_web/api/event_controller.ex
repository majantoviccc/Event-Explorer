defmodule EventExplorerWeb.Api.EventController do
  @moduledoc """
  API controller for managing events.

  Supports listing, retrieving, creating, updating,
  deleting events and fetching related events.
  """

  use EventExplorerWeb, :controller

  alias EventExplorer.Events

  @doc "Returns a list of events with optional filters."
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    events = Events.list_events(params)
    render(conn, :index, events: events)
  end

  @doc "Returns a single event by ID."
  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    case Events.get_event(id) do
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Event not found"})

      {:ok, event} ->
        render(conn, :show, event: event)
    end
  end

  @doc "Creates a new event."
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"event" => event_params}) do
    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_status(:created)
        |> render(:show, event: event)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  @doc "Updates an existing event."
  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id, "event" => event_params}) do
    case Events.get_event(id) do
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Event not found"})

      {:ok, event} ->
        case Events.update_event(event, event_params) do
          {:ok, event} ->
            conn
            |> put_status(:ok)
            |> render(:show, event: event)

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{errors: format_errors(changeset)})
        end
    end
  end

  @doc "Deletes an event."
  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    case Events.get_event(id) do
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Event not found"})

      {:ok, event} ->
        case Events.delete_event(event) do
          {:ok, _} ->
            send_resp(conn, :no_content, "")

          {:error, _} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Could not delete event"})
        end
    end
  end

  @doc "Returns related events based on city or categories."
  @spec related(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def related(conn, %{"id" => id}) do
    case Events.get_event(id) do
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "not_found"})

      {:ok, event} ->
        events = Events.related_events(event)
        render(conn, :index, events: events)
    end
  end


  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
