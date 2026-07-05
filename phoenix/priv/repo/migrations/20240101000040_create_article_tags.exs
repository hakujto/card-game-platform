defmodule CardsProject.Repo.Migrations.CreateArticleTags do
  use Ecto.Migration

  def change do
    create table(:article_tags) do
      add :name, :string
      add :slug, :string

      timestamps()
    end
    create unique_index(:article_tags, [:slug])
  end
end
