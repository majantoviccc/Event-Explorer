defmodule EventExplorer.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :title, :string
    field :date, :date
    field :time, :time
    field :price, :float
    field :image, :string
    field :description, :string
    field :featured, :boolean

    many_to_many :categories, EventExplorer.Categories.Category,
      join_through: "events_categories",
      on_replace: :delete

    belongs_to :venue, EventExplorer.Venues.Venue

    timestamps()
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :title,
      :date,
      :time,
      :price,
      :image,
      :description,
      :featured,
      :venue_id
    ])
    |> validate_required([:title, :date, :time, :venue_id])
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end
end
