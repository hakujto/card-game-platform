defmodule CardsProject.Repo.Migrations.CreateAchievements do
  use Ecto.Migration

  def change do
    create table(:achievements) do
      add :name, :string
      add :description, :string
      add :icon_url, :string, null: true
      add :points, :integer, default: 10
      add :rarity, :string, default: "Common"
      add :is_hidden, :boolean, default: false

      timestamps()
    end
  end
end
