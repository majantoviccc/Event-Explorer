defmodule EventExplorer.Venues.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "venues" do
    field :name, :string
    belongs_to :city, EventExplorer.Cities.City
    has_many :events, EventExplorer.Events.Event
    timestamps()
  end

  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:name, :city_id])
    |> validate_required([:name, :city_id])
  end
end
