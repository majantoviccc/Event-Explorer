defmodule EventExplorerWeb.Api.CityControllerTest do
  use EventExplorerWeb.ConnCase, async: true

  alias EventExplorer.Repo
  alias EventExplorer.Cities.City


      test "returns all cities", %{conn: conn} do

      city1= Repo.insert!(%City{name: "New York"})
      city2= Repo.insert!(%City{name: "Los Angeles"})

      conn = get(conn, "/api/cities")

      response = json_response(conn, 200)

      assert is_list(response["cities"])
      assert length(response["cities"]) == 2

      names = Enum.map(response["cities"], & &1["name"])

      assert "New York" in names
      assert "Los Angeles" in names



    end

    test "returns empty list when no cities exist", %{conn: conn} do
      conn = get(conn, "/api/cities")

      response = json_response(conn, 200)

      assert response["cities"] == []
    end
  end
