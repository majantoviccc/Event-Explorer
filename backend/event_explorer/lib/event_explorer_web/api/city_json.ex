defmodule EventExplorerWeb.Api.CityJSON do
  @moduledoc """
  JSON views for city API responses.
  """

  @doc "Renders a list of cities."
  @spec index(map()) :: map()
  def index(%{cities: cities}) do
    %{
      cities: Enum.map(cities, &data/1)
    }
  end

  @doc false
  defp data(city) do
    %{
      id: city.id,
      name: city.name
    }
  end
end
