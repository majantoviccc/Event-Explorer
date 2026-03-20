defmodule EventExplorer.Cities.City do

  use Ecto.Schema
  import Ecto.Changeset

   schema "cities" do
    field :name , :string
    has_many  :venues, EventExplorer.Venues.Venue
     timestamps()

   end

   def changeset(city, attrs) do

    city
    |> cast(attrs,[:name])
    |> validate_required([:name])

   end


end
