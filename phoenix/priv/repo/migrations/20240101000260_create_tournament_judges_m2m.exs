defmodule CardsProject.Repo.Migrations.CreateTournamentJudgesM2m do
  use Ecto.Migration

  def change do
    create table(:tournament_judges_m2m, primary_key: false) do
      add :left_id, references(:tournaments, on_delete: :delete_all), null: false
      add :right_id, references(:players, on_delete: :delete_all), null: false
    end

    create unique_index(:tournament_judges_m2m, [:left_id, :right_id])
  end
end
