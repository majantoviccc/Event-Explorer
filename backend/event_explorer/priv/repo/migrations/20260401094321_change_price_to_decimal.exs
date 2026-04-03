defmodule EventExplorer.Repo.Migrations.ChangePriceToDecimal do
  use Ecto.Migration

  def change do
    alter table(:events) do
      modify :price, :decimal
    end
  end
end
