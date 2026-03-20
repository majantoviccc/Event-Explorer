defmodule EventExplorerWeb.Api.EventController do
  use EventExplorerWeb, :controller

  alias EventExplorer.Events

  def index(conn, params) do
    events = Events.list_events(params)
    render(conn, :index, events: events)
  end

 def show(conn, %{"id" => id}) do
  case Events.get_event(id) do
    nil ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "Event not found"})

    event ->
      render(conn, :show, event: event)
  end
end


  def create(conn, params) do

    case Events.create_event(params) do

      {:ok, event} ->
        conn
        |>put_status(:created)
        |> render(:show, event: event)
       {:error, changeset} ->
         conn
         |> put_status(:unprocessable_entity)
         |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id"=> id}= params) do

      event = Events.get_event(id)
      case Events.update_event(event, params ) do

      {:ok, event} ->
        conn
        |>put_status(:ok)
        |> render(:show, event: event)


      {:error, changeset} ->
       conn
          |> put_status(:unprocessable_entity)
          |> json(%{errors: format_errors(changeset)})

    end

  end

  def delete(conn, %{"id" => id}) do
  case Events.get_event(id) do
    nil ->
      conn
      |> put_status(:not_found)
      |> json(%{error: "Event not found"})

    event ->
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


 defp format_errors(changeset) do
  Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end)
end

end
