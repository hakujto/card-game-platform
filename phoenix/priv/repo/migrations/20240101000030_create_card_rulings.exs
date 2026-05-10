defmodule CardsProject.Repo.Migrations.CreateCardRulings do
  use Ecto.Migration

  def change do
    create table(:card_rulings) do
      add :ruling_text, :string
      add :published_at, :date
      add :source, :string
      add :card_id, references(:cards, on_delete: :nilify_all)

      timestamps()
    end
    create index(:card_rulings, [:card_id])
  end
end
