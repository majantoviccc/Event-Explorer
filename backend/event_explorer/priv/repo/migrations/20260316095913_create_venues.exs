defmodule EventExplorer.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues) do
      add :name, :string
      add :city_id, references(:cities, on_delete: :nothing)
      timestamps()

    end
    create index(:venues, [:city_id])
  end




end
