defmodule EventExplorerWeb.Api.VenueController do
  @moduledoc """
  API controller for managing venues.
  """

  use EventExplorerWeb, :controller

  alias EventExplorer.Venues

  @doc "Returns a list of all venues with their cities."
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    venues = Venues.list_venues()
    render(conn, :index, venues: venues)
  end
end
