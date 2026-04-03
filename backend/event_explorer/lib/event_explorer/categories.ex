defmodule EventExplorer.Categories do
  @moduledoc """
  Context module for managing event categories.
  """

  alias EventExplorer.Repo
  alias EventExplorer.Categories.Category

  @doc "Returns all categories."
  @spec list_categories() :: list(map())
  def list_categories do
    Repo.all(Category)
  end
end
