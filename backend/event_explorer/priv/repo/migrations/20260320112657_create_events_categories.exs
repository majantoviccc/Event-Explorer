defmodule EventExplorer.Repo.Migrations.CreateEventsCategories do
  use Ecto.Migration

  def change do
    create table(:events_categories) do
      add :event_id, references(:events, on_delete: :delete_all)
      add :category_id, references(:categories, on_delete: :delete_all)
    end

    create unique_index(:events_categories, [:event_id, :category_id])
  end
end
