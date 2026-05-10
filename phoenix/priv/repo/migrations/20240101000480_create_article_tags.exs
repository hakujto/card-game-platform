defmodule CardsProject.Repo.Migrations.CreateArticleTags do
  use Ecto.Migration

  def change do
    create table(:article_tags) do
      add :name, :string
      add :slug, :string

      timestamps()
    end
  end
end
