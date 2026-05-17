defmodule CardsProject.Tournaments.TournamentRegistration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournament_registrations" do
    field :status, :string
    field :seed, :integer
    field :final_standing, :integer
    field :points_earned, :integer, default: 0
    field :registered_at, :naive_datetime
    belongs_to :tournament, CardsProject.Tournaments.Tournament
    belongs_to :player, CardsProject.Players.Player
    belongs_to :deck, CardsProject.Cards.Deck

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:points_earned, :registered_at, :status, :seed, :final_standing, :tournament_id, :player_id, :deck_id])
    |> validate_required([:points_earned, :registered_at])
    |> validate_inclusion(:status, ["Registered", "Waitlisted", "Withdrawn", "Disqualified"])
  end

  # ── Business operations ────────────────────────────────────────────

  def withdraw(_record) do
    # TODO: implement TournamentRegistration.withdraw
    :ok
  end

  def disqualify(_record, _reason) do
    # TODO: implement TournamentRegistration.disqualify
    :ok
  end

  def promote_from_waitlist(_record) do
    # TODO: implement TournamentRegistration.promote_from_waitlist
    :ok
  end
end
