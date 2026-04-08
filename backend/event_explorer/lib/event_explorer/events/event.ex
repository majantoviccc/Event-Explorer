defmodule EventExplorer.Events.Event do
  @moduledoc """
  Schema for events.

  Represents an event with details such as title, date, time,
  price, description, image, and associations with categories and venue.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias EventExplorer.Categories.Category
  alias EventExplorer.Venues.Venue

  schema "events" do
    field :title, :string
    field :date, :date
    field :time, :time
    field :price, :decimal
    field :image, :string
    field :description, :string
    field :featured, :boolean, default: false
    field :public_id, :string

    many_to_many :categories, Category,
      join_through: "events_categories",
      on_replace: :delete

    belongs_to :venue, Venue

    timestamps()
  end

  @doc "Builds a changeset for creating or updating an event."
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :title,
      :date,
      :time,
      :price,
      :description,
      :featured,
      :image,
      :venue_id,
      :public_id
    ])
    |> validate_required([:title, :date, :time, :venue_id])
    |> validate_number(:price, greater_than_or_equal_to: 0)
    |> validate_length(:title, max: 255)
    |> validate_length(:description, max: 255)
    |> foreign_key_constraint(:venue_id)
  end
end
