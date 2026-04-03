defmodule EventExplorer.CitiesTest do
  use EventExplorer.DataCase

  alias EventExplorer.Cities
  alias EventExplorer.Repo
  alias EventExplorer.Cities.City

  test "list_cities returns all cities" do
    {:ok, c1} = Repo.insert(%City{name: "Podgorica"})
    {:ok, c2} = Repo.insert(%City{name: "Budva"})

    cities = Cities.list_cities()

    assert length(cities) == 2
    names = Enum.map(cities, & &1.name)
    assert "Podgorica" in names
    assert "Budva" in names
  end

  test "city changeset is valid with valid data" do
    changeset =
      City.changeset(%City{}, %{
        name: "Podgorica"
      })

    assert changeset.valid?
  end

  test "city changeset is invalid without name" do
    changeset = City.changeset(%City{}, %{})

    refute changeset.valid?
  end

  test "city changeset is invalid when name is too long" do
    long_name = String.duplicate("a", 256)

    changeset =
      City.changeset(%City{}, %{
        name: long_name
      })

    refute changeset.valid?
  end

  test "city name must be unique" do
    {:ok, _} = Repo.insert(%City{name: "Podgorica"})

    changeset =
      City.changeset(%City{}, %{
        name: "Podgorica"
      })

    assert {:error, _} = Repo.insert(changeset)
  end
end
