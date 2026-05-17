defmodule CardsProject.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string
      add :slug, :string
      add :body, :string
      add :excerpt, :string, null: true
      add :cover_image_url, :string, null: true
      add :status, :string, default: "Draft"
      add :article_type, :string, default: "Guide"
      add :view_count, :integer, default: 0
      add :published_at, :naive_datetime, null: true
      add :created_at, :naive_datetime
      add :author_id, references(:players, on_delete: :nilify_all)
      add :featured_deck_id, references(:decks, on_delete: :nilify_all), null: true
      add :comments_id, references(:article_comments, on_delete: :nilify_all)

      timestamps()
    end
    create index(:articles, [:author_id])
    create index(:articles, [:featured_deck_id])
  end
end
