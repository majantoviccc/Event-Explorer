defmodule EventExplorerWeb.Api.CityController do
  @moduledoc """
  API controller for managing cities.
  """

  use EventExplorerWeb, :controller

  alias EventExplorer.Cities

  @doc "Returns a list of all cities."
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    cities = Cities.list_cities()
    render(conn, :index, cities: cities)
  end
end
