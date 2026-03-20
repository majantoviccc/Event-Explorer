defmodule EventExplorerWeb.Api.CityJSON do



  def index(%{cities: cities}) do

     %{
         cities: for(city <- cities, do: data(city))

     }


  end

  defp data(city) do

    %{
      id: city.id,
      name: city.name

    }

  end

end
