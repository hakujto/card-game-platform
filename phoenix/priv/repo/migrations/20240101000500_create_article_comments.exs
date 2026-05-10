defmodule CardsProject.Repo.Migrations.CreateArticleComments do
  use Ecto.Migration

  def change do
    create table(:article_comments) do
      add :body, :string
      add :is_hidden, :boolean, default: false
      add :created_at, :naive_datetime
      add :article_id, references(:articles, on_delete: :nilify_all), null: true
      add :author_id, references(:players, on_delete: :nilify_all)
      add :parent_comment_id, references(:article_comments, on_delete: :nilify_all), null: true

      timestamps()
    end
    create index(:article_comments, [:article_id])
    create index(:article_comments, [:author_id])
    create index(:article_comments, [:parent_comment_id])
  end
end
