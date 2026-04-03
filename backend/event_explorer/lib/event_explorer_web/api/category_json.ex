defmodule EventExplorerWeb.Api.CategoryJSON do
  @moduledoc """
  JSON views for category API responses.
  """

  @doc "Renders a list of categories."
  @spec index(map()) :: map()
  def index(%{categories: categories}) do
    %{
      categories: for(category <- categories, do: data(category))
    }
  end

  @doc false
  defp data(category) do
    %{
      id: category.id,
      name: category.name
    }
  end
end
