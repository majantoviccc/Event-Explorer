defmodule EventExplorer.Repo.Migrations.AddPublicIdToEvents do
  use Ecto.Migration

  def change do
    alter table(:events) do
      add :public_id, :string
    end
  end
end
