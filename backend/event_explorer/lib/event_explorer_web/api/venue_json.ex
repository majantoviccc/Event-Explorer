defmodule EventExplorerWeb.Api.VenueJSON do
  def index(%{venues: venues}) do
    %{
      venues: for(venue <- venues, do: data(venue))
    }
  end

  defp data(venue) do
    %{
      id: venue.id,
      name: venue.name
    }
  end
end
