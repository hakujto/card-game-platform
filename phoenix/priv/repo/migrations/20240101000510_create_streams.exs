defmodule CardsProject.Repo.Migrations.CreateStreams do
  use Ecto.Migration

  def change do
    create table(:streams) do
      add :title, :string
      add :stream_url, :string
      add :platform, :string, default: "Twitch"
      add :status, :string, default: "Scheduled"
      add :viewer_count_peak, :integer, default: 0
      add :scheduled_start, :naive_datetime
      add :actual_start, :naive_datetime, null: true
      add :ended_at, :naive_datetime, null: true
      add :vod_url, :string, null: true
      add :tournament_id, references(:tournaments, on_delete: :nilify_all), null: true
      add :streamer_id, references(:players, on_delete: :nilify_all)

      timestamps()
    end
    create index(:streams, [:tournament_id])
    create index(:streams, [:streamer_id])
  end
end
