defmodule EventExplorer.Repo.Migrations.AddConstraints do
  use Ecto.Migration

  def change do
    create unique_index(:cities, [:name])

    create unique_index(:categories, [:name])

    create unique_index(:venues, [:name, :city_id])
  end
end
