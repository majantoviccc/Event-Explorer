defmodule EventExplorer.Repo.Migrations.AddDefaultToFeatured do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify :featured, :boolean, default: false, null: false
    end
  end
end
