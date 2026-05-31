defmodule CardsProject.Content.Stream do
  use Ecto.Schema
  import Ecto.Changeset

  schema "streams" do
    field :title, :string
    field :stream_url, :string
    field :status, :string
    field :platform, :string
    field :language, :string
    field :is_official, :boolean, default: false
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
    |> cast(attrs, [:title, :stream_url, :is_official, :viewer_count_peak, :scheduled_start, :status, :platform, :language, :actual_start, :ended_at, :vod_url, :tournament_id, :streamer_id])
    |> validate_required([:title, :stream_url, :is_official, :viewer_count_peak, :scheduled_start])
    |> validate_inclusion(:status, ["Scheduled", "Live", "Ended"])
    |> validate_inclusion(:platform, ["Twitch", "YouTube", "KickStream", "Platform"])
    |> validate_inclusion(:language, ["EN", "DE", "FR", "IT", "ES", "JP", "PT"])
    |> validate_number(:viewer_count_peak, greater_than_or_equal_to: 0, message: "Peak viewer count must not be negative")
    |> then(fn cs ->
      if not is_nil(get_field(cs, :actual_start)) and (get_field(cs, :status) != "Live") do
        Ecto.Changeset.add_error(cs, :status, "actual_start_requires_live_or_ended validation failed")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if not is_nil(get_field(cs, :ended_at)) and (get_field(cs, :status) != "Ended") do
        Ecto.Changeset.add_error(cs, :status, "ended_at can only be set when stream status is Ended")
      else
        cs
      end
    end)
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

  # ── Lifecycle state machine ─────────────────────────────────────────
  @allowed_transitions %{
    "Scheduled" => ["Live"],
    "Live" => ["Ended"]
  }

  def assert_transition(%__MODULE__{status: current}, to) do
    allowed = Map.get(@allowed_transitions, current, [])
    if to in allowed do
      :ok
    else
      {:error, "Transition #{current} -> #{to} not allowed"}
    end
  end
end
