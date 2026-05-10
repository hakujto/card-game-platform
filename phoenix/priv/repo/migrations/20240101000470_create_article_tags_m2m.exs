defmodule CardsProject.Repo.Migrations.CreateArticleTagsM2m do
  use Ecto.Migration

  def change do
    create table(:article_tags_m2m, primary_key: false) do
      add :left_id, references(:articles, on_delete: :delete_all), null: false
      add :right_id, references(:article_tags, on_delete: :delete_all), null: false
    end

    create unique_index(:article_tags_m2m, [:left_id, :right_id])
  end
end
