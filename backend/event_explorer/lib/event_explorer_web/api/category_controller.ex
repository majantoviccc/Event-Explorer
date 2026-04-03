defmodule EventExplorerWeb.Api.CategoryController do
  @moduledoc """
  API controller for managing categories.
  """

  use EventExplorerWeb, :controller

  alias EventExplorer.Repo
  alias EventExplorer.Categories.Category

  @doc "Returns a list of all categories."
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    categories = Repo.all(Category)
    render(conn, :index, categories: categories)
  end
end
