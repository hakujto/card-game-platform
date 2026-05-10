defmodule CardsProject.Cards.Deck do
  use Ecto.Schema
  import Ecto.Changeset

  schema "decks" do
    field :name, :string
    field :description, :string
    field :format, :string
    field :is_public, :boolean, default: false
    field :is_tournament_legal, :boolean, default: false
    field :archetype, :string
    field :wins, :integer, default: 0
    field :losses, :integer, default: 0
    field :created_at, :naive_datetime
    belongs_to :player, CardsProject.Players.Player
    many_to_many :cards, CardsProject.Cards.Card, join_through: "deck_cards_m2m"
    many_to_many :sideboard_cards, CardsProject.Cards.Card, join_through: "deck_sideboard_cards_m2m"
    many_to_many :tags, CardsProject.Cards.DeckTag, join_through: "deck_tags_m2m"

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :is_public, :is_tournament_legal, :wins, :losses, :created_at, :description, :format, :archetype, :player_id])
    |> validate_required([:name, :is_public, :is_tournament_legal, :wins, :losses, :created_at])
    |> validate_inclusion(:format, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
    |> validate_inclusion(:archetype, ["Aggro", "Control", "Midrange", "Combo", "Prison", "Tempo"])
  end
end
