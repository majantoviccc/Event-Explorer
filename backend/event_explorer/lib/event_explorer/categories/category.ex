defmodule EventExplorer.Categories.Category do

  use Ecto.Schema
  import Ecto.Changeset


   schema "categories" do
     field :name, :string
     has_many :events, EventExplorer.Events.Event
      timestamps()
   end

   def changeset(category, attrs) do

    category
    |>cast(attrs, [:name])
    |> validate_required([:name])

   end




end
