defmodule EventExplorerWeb.Api.VenueJSON do
  @moduledoc """
  JSON views for venue API responses.
  """

  @doc "Renders a list of venues."
  @spec index(map()) :: map()
  def index(%{venues: venues}) do
    %{
      venues: Enum.map(venues, &data/1)
    }
  end

  defp data(venue) do
    %{
      id: venue.id,
      name: venue.name
    }
  end
end
