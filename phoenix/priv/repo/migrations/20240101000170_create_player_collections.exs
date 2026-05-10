defmodule CardsProject.Repo.Migrations.CreatePlayerCollections do
  use Ecto.Migration

  def change do
    create table(:player_collections) do
      add :quantity, :integer, default: 1
      add :foil, :boolean, default: false
      add :condition, :string, default: "Mint"
      add :acquired_at, :naive_datetime
      add :acquired_via, :string, default: "Purchase"
      add :player_id, references(:players, on_delete: :nilify_all)
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:player_collections, [:player_id])
    create index(:player_collections, [:card_id])
  end
end
