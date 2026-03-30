defmodule EventExplorerWeb.Api.VenueController do
  use EventExplorerWeb, :controller

  alias EventExplorer.Repo
  alias EventExplorer.Venues.Venue

  def index(conn, _params) do
    venues = Repo.all(Venue)
    render(conn, :index, venues: venues)
  end
end
