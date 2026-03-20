defmodule EventExplorerWeb.Api.CategoryController do
  use EventExplorerWeb, :controller

  alias EventExplorer.Repo
  alias EventExplorer.Categories.Category

  def index(conn, _params) do
    categories = Repo.all(Category)
    render(conn, :index, categories: categories)
  end
end
