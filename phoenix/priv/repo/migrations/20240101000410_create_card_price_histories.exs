defmodule CardsProject.Repo.Migrations.CreateCardPriceHistories do
  use Ecto.Migration

  def change do
    create table(:card_price_histories) do
      add :price_date, :date
      add :avg_price, :decimal
      add :min_price, :decimal
      add :max_price, :decimal
      add :volume, :integer
      add :foil, :boolean, default: false
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:card_price_histories, [:card_id])
  end
end
