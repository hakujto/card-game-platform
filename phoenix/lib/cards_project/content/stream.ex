defmodule CardsProject.Content.Stream do
  use Ecto.Schema
  import Ecto.Changeset

  schema "streams" do
    field :title, :string
    field :stream_url, :string
    field :platform, :string
    field :status, :string
    field :viewer_count_peak, :integer, default: 0
    field :scheduled_start, :naive_datetime
    field :actual_start, :naive_datetime
    field :ended_at, :naive_datetime
    field :vod_url, :string
    belongs_to :tournament, CardsProject.Tournaments.Tournament
    belongs_to :streamer, CardsProject.Players.Player

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:title, :stream_url, :viewer_count_peak, :scheduled_start, :platform, :status, :actual_start, :ended_at, :vod_url, :tournament_id, :streamer_id])
    |> validate_required([:title, :stream_url, :viewer_count_peak, :scheduled_start])
    |> validate_inclusion(:platform, ["Twitch", "YouTube", "KickStream", "Platform"])
    |> validate_inclusion(:status, ["Scheduled", "Live", "Ended"])
  end

  # ── Business operations ────────────────────────────────────────────

  def go_live(_record) do
    # TODO: implement Stream.go_live
    :ok
  end

  def end_action(_record) do
    # TODO: implement Stream.end_action
    :ok
  end

  def update_viewer_peak(_record, _count) do
    # TODO: implement Stream.update_viewer_peak
    :ok
  end

  def duration_minutes(_record) do
    # TODO: implement Stream.duration_minutes
    {:error, :not_implemented}
  end
end
