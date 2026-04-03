defmodule EventExplorer.VenuesTest do
  use EventExplorer.DataCase

  alias EventExplorer.Venues
  alias EventExplorer.Repo
  alias EventExplorer.Venues.Venue
  alias EventExplorer.Cities.City

  test "list_venues returns all venues with city" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})

    {:ok, v1} = Repo.insert(%Venue{name: "V1", city_id: city.id})
    {:ok, v2} = Repo.insert(%Venue{name: "V2", city_id: city.id})

    venues = Venues.list_venues()

    assert length(venues) == 2
    assert hd(venues).city.name == "Podgorica"
  end

  test "venue changeset is valid with valid data" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})

    changeset =
      Venue.changeset(%Venue{}, %{
        name: "V1",
        city_id: city.id
      })

    assert changeset.valid?
  end

  test "venue changeset is invalid without name" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})

    changeset =
      Venue.changeset(%Venue{}, %{
        city_id: city.id
      })

    refute changeset.valid?
  end

  test "venue changeset is invalid without city_id" do
    changeset =
      Venue.changeset(%Venue{}, %{
        name: "V1"
      })

    refute changeset.valid?
  end

  test "venue changeset is invalid when name is too long" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})

    long_name = String.duplicate("a", 256)

    changeset =
      Venue.changeset(%Venue{}, %{
        name: long_name,
        city_id: city.id
      })

    refute changeset.valid?
  end

  test "venue must have valid city_id (foreign key)" do
    changeset =
      Venue.changeset(%Venue{}, %{
        name: "V1",
        city_id: 9999
      })

    assert {:error, _} = Repo.insert(changeset)
  end

  test "venue name must be unique per city" do
    {:ok, city} = Repo.insert(%City{name: "Podgorica"})

    {:ok, _} =
      Repo.insert(%Venue{
        name: "V1",
        city_id: city.id
      })

    changeset =
      Venue.changeset(%Venue{}, %{
        name: "V1",
        city_id: city.id
      })

    assert {:error, _} = Repo.insert(changeset)
  end
end
