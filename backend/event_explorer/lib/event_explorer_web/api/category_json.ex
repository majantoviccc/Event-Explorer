defmodule EventExplorerWeb.Api.CategoryJSON do



  def index(%{categories: categories}) do

     %{
         categories: for(category <- categories, do: data(category))

     }


  end

  defp data(category) do

    %{
      id: category.id,
      name: category.name

    }

  end

end
