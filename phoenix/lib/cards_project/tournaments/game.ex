defmodule CardsProject.Tournaments.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :game_number, :integer
    field :winner_side, :string
    field :turns_played, :integer
    field :duration_seconds, :integer
    field :ended_by, :string
    field :replay_url, :string
    belongs_to :match, CardsProject.Tournaments.Match
    belongs_to :winner, CardsProject.Players.Player

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:game_number, :winner_side, :turns_played, :duration_seconds, :ended_by, :replay_url, :match_id, :winner_id])
    |> validate_required([:game_number])
    |> validate_inclusion(:winner_side, ["Player1", "Player2", "Draw"])
    |> validate_inclusion(:ended_by, ["Normal", "Timeout", "Concession", "DrawOffer"])
    |> validate_number(:game_number, greater_than_or_equal_to: 1, less_than_or_equal_to: 3, message: "Game number must be between 1 and 3 (best-of-3)")
    |> then(fn cs ->
      if not is_nil(get_field(cs, :turns_played)) and (not ((get_field(cs, :turns_played) || 0) > 0)) do
        Ecto.Changeset.add_error(cs, :turns_played, "Turns played must be greater than zero")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if not is_nil(get_field(cs, :duration_seconds)) and (not ((get_field(cs, :duration_seconds) || 0) > 0)) do
        Ecto.Changeset.add_error(cs, :duration_seconds, "Game duration must be greater than zero")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :winner_side) == "Draw" and (not is_nil(get_field(cs, :winner_id))) do
        Ecto.Changeset.add_error(cs, :winner_id, "A draw cannot have a winner")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if (not is_nil(get_field(cs, :winner_side)) and get_field(cs, :winner_side) != "Draw") and (is_nil(get_field(cs, :winner_id))) do
        Ecto.Changeset.add_error(cs, :winner_id, "A decisive game must have a winner player set")
      else
        cs
      end
    end)
  end

  # ── Business operations ────────────────────────────────────────────

  def record_winner(_record, _winner_side) do
    # TODO: implement Game.record_winner
    :ok
  end

  def duration_minutes(_record) do
    # TODO: implement Game.duration_minutes
    {:error, :not_implemented}
  end
end
