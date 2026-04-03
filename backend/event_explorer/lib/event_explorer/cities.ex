defmodule EventExplorer.Cities do
  @moduledoc """
  Context module for managing cities.
  """

  alias EventExplorer.Repo
  alias EventExplorer.Cities.City

  @doc "Returns all cities."
  @spec list_cities() :: list(map())
  def list_cities do
    Repo.all(City)
  end
end
