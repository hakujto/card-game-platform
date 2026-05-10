defmodule CardsProject.Players.PlayerCollection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "player_collections" do
    field :quantity, :integer, default: 1
    field :foil, :boolean, default: false
    field :condition, :string
    field :acquired_at, :naive_datetime
    field :acquired_via, :string
    belongs_to :player, CardsProject.Players.Player
    belongs_to :card, CardsProject.Cards.Card

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:quantity, :foil, :acquired_at, :condition, :acquired_via, :player_id, :card_id])
    |> validate_required([:quantity, :foil, :acquired_at])
    |> validate_inclusion(:condition, ["Mint", "NearMint", "Excellent", "Good", "Played"])
    |> validate_inclusion(:acquired_via, ["Purchase", "Trade", "TournamentReward", "Pack", "Craft"])
  end
end
