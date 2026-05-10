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
  end
end
