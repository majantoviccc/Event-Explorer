defmodule EventExplorerWeb.Api.VenueControllerTest do
  use EventExplorerWeb.ConnCase, async: true

  alias EventExplorer.Repo
  alias EventExplorer.Venues.Venue
  alias EventExplorer.Cities.City

  describe "GET /api/venues" do
    test "returns all venues with cities", %{conn: conn} do
      city = Repo.insert!(%City{name: "Podgorica"})

      venue1 =
        Repo.insert!(%Venue{
          name: "Stadium",
          city_id: city.id
        })

      venue2 =
        Repo.insert!(%Venue{
          name: "Club",
          city_id: city.id
        })

      conn = get(conn, "/api/venues")

      response = json_response(conn, 200)

      assert is_list(response["venues"])
      assert length(response["venues"]) == 2

      names =
        Enum.map(response["venues"], & &1["name"])

      assert "Stadium" in names
      assert "Club" in names
    end

    test "returns empty list when no venues exist", %{conn: conn} do
      conn = get(conn, "/api/venues")

      response = json_response(conn, 200)

      assert response["venues"] == []
    end
  end
end
