defmodule CardsProject.Repo.Migrations.CreateDeckTagAssignments do
  use Ecto.Migration

  def change do
    create table(:deck_tag_assignments) do
      add :deck_id, references(:decks, on_delete: :nilify_all)
      add :tag_id, references(:deck_tags, on_delete: :nilify_all)

      timestamps()
    end
    create index(:deck_tag_assignments, [:deck_id])
    create index(:deck_tag_assignments, [:tag_id])
  end
end
