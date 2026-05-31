defmodule CardsProject.Tournaments.TournamentRound do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournament_rounds" do
    field :round_number, :integer
    field :status, :string
    field :started_at, :naive_datetime
    field :ended_at, :naive_datetime
    field :time_limit_minutes, :integer, default: 50
    belongs_to :tournament, CardsProject.Tournaments.Tournament
    belongs_to :matches, CardsProject.Tournaments.Match

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:round_number, :time_limit_minutes, :status, :started_at, :ended_at, :tournament_id])
    |> validate_required([:round_number, :time_limit_minutes])
    |> validate_inclusion(:status, ["Pending", "Active", "Completed"])
    |> validate_number(:round_number, greater_than: 0, message: "Round number must be greater than zero")
    |> validate_number(:time_limit_minutes, greater_than: 0, message: "Round time limit must be greater than zero")
    |> then(fn cs ->
      if not is_nil(get_field(cs, :ended_at)) and (not ((get_field(cs, :ended_at) || 0) > get_field(cs, :started_at))) do
        Ecto.Changeset.add_error(cs, :ended_at, "Round end time must be after start time")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :status) == "Completed" and (is_nil(get_field(cs, :started_at))) do
        Ecto.Changeset.add_error(cs, :started_at, "Completed round must have a start time")
      else
        cs
      end
    end)
  end

  # ── Business operations ────────────────────────────────────────────

  def start(_record) do
    # TODO: implement TournamentRound.start
    :ok
  end

  def complete(_record) do
    # TODO: implement TournamentRound.complete
    :ok
  end

  def generate_pairings(_record) do
    # TODO: implement TournamentRound.generate_pairings
    :ok
  end

  def is_time_expired(_record) do
    # TODO: implement TournamentRound.is_time_expired
    {:error, :not_implemented}
  end
end
