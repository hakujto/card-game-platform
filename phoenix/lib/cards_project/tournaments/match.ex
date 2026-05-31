defmodule CardsProject.Tournaments.Match do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :table_number, :integer
    field :status, :string
    field :player1_wins, :integer, default: 0
    field :player2_wins, :integer, default: 0
    field :started_at, :naive_datetime
    field :ended_at, :naive_datetime
    field :result_notes, :string
    belongs_to :round, CardsProject.Tournaments.TournamentRound
    belongs_to :player1, CardsProject.Players.Player
    belongs_to :player2, CardsProject.Players.Player
    belongs_to :games, CardsProject.Tournaments.Game

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:player1_wins, :player2_wins, :table_number, :status, :started_at, :ended_at, :result_notes, :round_id, :player1_id, :player2_id])
    |> validate_required([:player1_wins, :player2_wins])
    |> validate_inclusion(:status, ["Pending", "Active", "Completed", "BYE", "Draw"])
    |> then(fn cs ->
      if get_field(cs, :status) == "BYE" and (not is_nil(get_field(cs, :player2_id))) do
        Ecto.Changeset.add_error(cs, :player2_id, "BYE match must not have a second player")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if not is_nil(get_field(cs, :ended_at)) and (not ((get_field(cs, :ended_at) || 0) > get_field(cs, :started_at))) do
        Ecto.Changeset.add_error(cs, :ended_at, "Match end time must be after start time")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :status) == "Completed" and (is_nil(get_field(cs, :started_at))) do
        Ecto.Changeset.add_error(cs, :started_at, "Completed match must have a start time")
      else
        cs
      end
    end)
  end

  # ── Business operations ────────────────────────────────────────────

  def record_result(_record, _p1_wins, _p2_wins) do
    # TODO: implement Match.record_result
    :ok
  end

  def finalize_result(_record) do
    # TODO: implement Match.finalize_result
    :ok
  end

  def determine_winner(_record) do
    # TODO: implement Match.determine_winner
    {:error, :not_implemented}
  end

  def concede(_record, _player_id) do
    # TODO: implement Match.concede
    :ok
  end

  def draw(_record) do
    # TODO: implement Match.draw
    :ok
  end

  # ── Lifecycle state machine ─────────────────────────────────────────
  @allowed_transitions %{
    "Pending" => ["Active", "BYE"],
    "Active" => ["Completed", "Draw"]
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
