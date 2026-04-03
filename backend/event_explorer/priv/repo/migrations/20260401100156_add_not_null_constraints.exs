defmodule EventExplorer.Repo.Migrations.AddNotNullConstraints do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify :title, :string, null: false
      modify :date, :date, null: false
      modify :time, :time, null: false
      modify :venue_id, :bigint, null: false
    end

    alter table(:cities) do
      modify :name, :string, null: false
    end

    alter table(:categories) do
      modify :name, :string, null: false
    end

    alter table(:venues) do
      modify :name, :string, null: false
      modify :city_id, :bigint, null: false
    end
  end
end
