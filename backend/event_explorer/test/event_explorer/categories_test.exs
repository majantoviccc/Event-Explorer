defmodule EventExplorer.CategoriesTest do
  use EventExplorer.DataCase

  alias EventExplorer.Categories
  alias EventExplorer.Repo
  alias EventExplorer.Categories.Category

  test "list_categories returns all categories" do
    {:ok, c1} = Repo.insert(%Category{name: "Music"})
    {:ok, c2} = Repo.insert(%Category{name: "Tech"})

    categories = Categories.list_categories()

    assert length(categories) == 2
  end

  test "category changeset is valid with valid data" do
    changeset =
      Category.changeset(%Category{}, %{
        name: "Music"
      })

    assert changeset.valid?
  end

  test "category changeset is invalid without name" do
    changeset = Category.changeset(%Category{}, %{})

    refute changeset.valid?
  end

  test "category changeset is invalid when name is too long" do
    long_name = String.duplicate("a", 256)

    changeset =
      Category.changeset(%Category{}, %{
        name: long_name
      })

    refute changeset.valid?
  end

  test "category name must be unique" do
    {:ok, _} = Repo.insert(%Category{name: "Music"})

    changeset =
      Category.changeset(%Category{}, %{
        name: "Music"
      })

    assert {:error, _} = Repo.insert(changeset)
  end
end
