defmodule CardsProject.Repo.Migrations.CreateDeckTags do
  use Ecto.Migration

  def change do
    create table(:deck_tags) do
      add :name, :string
      add :slug, :string, null: true
      add :color, :string, null: true

      timestamps()
    end
  end
end
