defmodule EventExplorerWeb.Api.CityController do
  use EventExplorerWeb, :controller

  alias EventExplorer.Repo
  alias EventExplorer.Cities.City

  def index(conn, _params) do
    cities = Repo.all(City)
    render(conn, :index, cities: cities)
  end
end
