defmodule EventExplorerWeb.Api.CategoryControllerTest do
  use EventExplorerWeb.ConnCase, async: true

  alias EventExplorer.Repo
  alias EventExplorer.Categories.Category

  test "returns all categories", %{conn: conn} do
    category1 = Repo.insert!(%Category{name: "Music"})
    category2 = Repo.insert!(%Category{name: "Sports"})

    conn = get(conn, "/api/categories")

    response = json_response(conn, 200)

    assert is_list(response["categories"])
    assert length(response["categories"]) == 2

    names =
      Enum.map(response["categories"], & &1["name"])

    assert "Music" in names
    assert "Sports" in names
  end

  test "returns empty list when no categories exist", %{conn: conn} do
    conn = get(conn, "/api/categories")

    response = json_response(conn, 200)

    assert response["categories"] == []
  end
end
