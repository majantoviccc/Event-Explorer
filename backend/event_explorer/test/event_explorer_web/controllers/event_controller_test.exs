defmodule EventExplorerWeb.Api.EventControllerTest do
  use EventExplorerWeb.ConnCase, async: true

  alias EventExplorer.Repo
  alias EventExplorer.Events.Event
  alias EventExplorer.Cities.City
  alias EventExplorer.Venues.Venue
  alias EventExplorer.Categories.Category

  defp create_event_fixture() do
    city = Repo.insert!(%City{name: "Podgorica"})

    venue =
      Repo.insert!(%Venue{
        name: "Stadium",
        city_id: city.id
      })

    category =
      Repo.insert!(%Category{
        name: "Music"
      })

    event =
      Repo.insert!(%Event{
        title: "Concert",
        description: "Great event",
        venue_id: venue.id,
        date: ~D[2026-01-01],
        time: ~T[20:00:00],
        price: Decimal.new("10.0"),
        image: "test.jpg",
        featured: false
      })

    event = Repo.preload(event, [:categories, venue: :city])
    %{event | categories: [category]}
  end

  describe "GET /api/events" do
    test "returns list of events", %{conn: conn} do
      _event = create_event_fixture()

      conn = get(conn, "/api/events")
      response = json_response(conn, 200)

      assert is_list(response["events"])
      assert length(response["events"]) >= 1
    end
  end

  describe "GET /api/events/:id" do
    test "returns event when exists", %{conn: conn} do
      event = create_event_fixture()

      conn = get(conn, "/api/events/#{event.id}")
      response = json_response(conn, 200)

      assert response["id"] == event.id
      assert response["title"] == "Concert"
      assert response["venue"]["name"] == "Stadium"
      assert response["city"]["name"] == "Podgorica"
    end

    test "returns 404 when event does not exist", %{conn: conn} do
      conn = get(conn, "/api/events/999999")

      assert json_response(conn, 404)["error"] == "Event not found"
    end
  end

  describe "POST /api/events" do
    test "creates event with valid data", %{conn: conn} do
      city = Repo.insert!(%City{name: "Podgorica"})

      venue =
        Repo.insert!(%Venue{
          name: "Stadium",
          city_id: city.id
        })

     params = %{
  "title" => "Concert",
  "description" => "Great event",
  "venue_id" => venue.id,
  "date" => "2026-01-01",
  "time" => "20:00:00"
}

      conn = post(conn, "/api/events", %{"event" => params})
      response = json_response(conn, 201)

      assert response["id"] != nil
    end

    test "returns error with invalid data", %{conn: conn} do
      conn = post(conn, "/api/events", %{"event" => %{}})

      assert json_response(conn, 422)
    end
  end

  describe "PUT /api/events/:id" do
    test "updates event", %{conn: conn} do
      event = create_event_fixture()

      conn =
        put(conn, "/api/events/#{event.id}", %{
          "event" => %{"title" => "Updated"}
        })

      response = json_response(conn, 200)

      assert response["title"] == "Updated"
    end

    test "returns 404 if event not found", %{conn: conn} do
      conn =
        put(conn, "/api/events/999", %{
          "event" => %{"title" => "Updated"}
        })

      assert json_response(conn, 404)["error"] == "Event not found"
    end
  end

  describe "DELETE /api/events/:id" do
    test "deletes event", %{conn: conn} do
      event = create_event_fixture()

      conn = delete(conn, "/api/events/#{event.id}")

      assert response(conn, 204)
    end

    test "returns 404 if event not found", %{conn: conn} do
      conn = delete(conn, "/api/events/999")

      assert json_response(conn, 404)["error"] == "Event not found"
    end
  end

  describe "GET /api/events/:id/related" do
    test "returns related events", %{conn: conn} do
      event = create_event_fixture()

      conn = get(conn, "/api/events/#{event.id}/related")
      response = json_response(conn, 200)

      assert is_list(response["events"])
    end

    test "returns 404 if event not found", %{conn: conn} do
      conn = get(conn, "/api/events/999/related")

      assert json_response(conn, 404)["error"] == "not_found"
    end
  end
end
