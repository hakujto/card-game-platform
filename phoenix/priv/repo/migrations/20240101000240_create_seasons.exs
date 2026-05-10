defmodule CardsProject.Repo.Migrations.CreateSeasons do
  use Ecto.Migration

  def change do
    create table(:seasons) do
      add :name, :string
      add :start_date, :date
      add :end_date, :date
      add :format, :string, default: "Standard"
      add :is_active, :boolean, default: false
      add :reward_description, :string, null: true

      timestamps()
    end
  end
end
