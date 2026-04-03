defmodule EventExplorer.Venues do
  @moduledoc """
  Context module for managing venues and their associated cities.
  """

  import Ecto.Query

  alias EventExplorer.Repo
  alias EventExplorer.Venues.Venue

  @doc "Returns all venues with preloaded city."
  @spec list_venues() :: list(map())
  def list_venues do
    Repo.all(from v in Venue, preload: [:city])
  end
end
