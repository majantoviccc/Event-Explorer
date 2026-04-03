defmodule EventExplorer.Cities.City do
  @moduledoc """
  Schema for cities.

  Represents a city that can have multiple venues.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias EventExplorer.Venues.Venue

  schema "cities" do
    field :name, :string

    has_many :venues, Venue

    timestamps()
  end

  @doc "Builds a changeset for creating or updating a city."
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(city, attrs) do
    city
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
    |> unique_constraint(:name)
  end
end
