defmodule EventExplorer.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string
      add :date, :date
      add :time, :time
      add :price, :float
      add :image, :string
      add :description, :string
      add :featured, :boolean

      add :venue_id, references(:venues, on_delete: :nothing)

      timestamps()
    end

    create index(:events, [:venue_id])
  end
end
