defmodule EventExplorer.Categories.Category do
  @moduledoc """
  Schema for categories.

  Represents a category that can be assigned to multiple events.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias EventExplorer.Events.Event

  schema "categories" do
    field :name, :string

    many_to_many :events, Event,
      join_through: "events_categories"

    timestamps()
  end

  @doc "Builds a changeset for creating or updating a category."
  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
    |> unique_constraint(:name)
  end
end
