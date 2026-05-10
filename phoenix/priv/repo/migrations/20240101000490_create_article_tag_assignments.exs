defmodule CardsProject.Repo.Migrations.CreateArticleTagAssignments do
  use Ecto.Migration

  def change do
    create table(:article_tag_assignments) do
      add :article_id, references(:articles, on_delete: :nilify_all)
      add :tag_id, references(:article_tags, on_delete: :nilify_all)

      timestamps()
    end
    create index(:article_tag_assignments, [:article_id])
    create index(:article_tag_assignments, [:tag_id])
  end
end
