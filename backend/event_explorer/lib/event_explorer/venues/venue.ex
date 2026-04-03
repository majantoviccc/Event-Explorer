defmodule EventExplorer.Venues.Venue do
  @moduledoc """
  Schema for venues.

  Represents a location where events are held.
  Each venue belongs to a city and can have multiple events.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias EventExplorer.Cities.City
  alias EventExplorer.Events.Event

  schema "venues" do
    field :name, :string

    belongs_to :city, City
    has_many :events, Event

    timestamps()
  end

  @doc "Builds a changeset for creating or updating a venue."
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:name, :city_id])
    |> validate_required([:name, :city_id])
    |> validate_length(:name, max: 255)
    |> foreign_key_constraint(:city_id)
    |> unique_constraint([:name, :city_id])
  end
end
