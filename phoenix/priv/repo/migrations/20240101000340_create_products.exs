defmodule CardsProject.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :product_type, :string, default: "SingleCard"
      add :price, :decimal
      add :stock, :integer, default: 0
      add :active, :boolean, default: true
      add :discount_percent, :integer, default: 0
      add :description, :string, null: true
      add :image_url, :string, null: true
      add :featured, :boolean, default: false
      add :card_id, references(:cards, on_delete: :nilify_all), null: true
      add :card_set_id, references(:card_sets, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:products, [:card_id])
    create index(:products, [:card_set_id])
  end
end
