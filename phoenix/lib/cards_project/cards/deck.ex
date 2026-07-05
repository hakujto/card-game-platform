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
    field :draws, :integer, default: 0
    field :created_at, :naive_datetime
    belongs_to :player, CardsProject.Players.Player
    many_to_many :cards, CardsProject.Cards.Card, join_through: "deck_cards"
    many_to_many :sideboard_cards, CardsProject.Cards.Card, join_through: "deck_sideboard_cards"
    many_to_many :tags, CardsProject.Cards.DeckTag, join_through: "deck_tag_assignments"
    has_many :deck_cards, CardsProject.Cards.DeckCard, foreign_key: :deck_id
    has_many :tag_assignments, CardsProject.Cards.DeckTagAssignment, foreign_key: :deck_id
    has_many :tournament_registrations, CardsProject.Tournaments.TournamentRegistration, foreign_key: :deck_id
    has_many :articles, CardsProject.Content.Article, foreign_key: :featured_deck_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :is_public, :is_tournament_legal, :wins, :losses, :draws, :created_at, :description, :format, :archetype, :player_id])
    |> validate_required([:name, :is_public, :is_tournament_legal, :wins, :losses, :draws, :created_at])
    |> validate_inclusion(:format, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
    |> validate_inclusion(:archetype, ["Aggro", "Control", "Midrange", "Combo", "Prison", "Tempo"])
    |> validate_number(:wins, greater_than_or_equal_to: 0, message: "Deck wins count must not be negative")
    |> validate_number(:losses, greater_than_or_equal_to: 0, message: "Deck losses count must not be negative")
    |> validate_number(:draws, greater_than_or_equal_to: 0, message: "Deck draws count must not be negative")
    |> then(fn cs ->
      if get_field(cs, :is_tournament_legal) == "true" and (get_field(cs, :is_public) != "true") do
        Ecto.Changeset.add_error(cs, :is_public, "Tournament-legal deck must be made public")
      else
        cs
      end
    end)
  end

  @doc false
  def update_changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :is_public, :is_tournament_legal, :description, :format, :archetype, :player_id])
    |> validate_required([:name, :is_public, :is_tournament_legal])
  end

  # ── Business operations ────────────────────────────────────────────

  def validate_size(_record) do
    # TODO: implement Deck.validate_size
    {:error, :not_implemented}
  end

  def add_card(_record, _card_id, _quantity) do
    # TODO: implement Deck.add_card
    :ok
  end

  def remove_card(_record, _card_id) do
    # TODO: implement Deck.remove_card
    :ok
  end

  def win_rate(_record) do
    # TODO: implement Deck.win_rate
    {:error, :not_implemented}
  end

  def clone(_record) do
    # TODO: implement Deck.clone
    {:error, :not_implemented}
  end

  def publish(_record) do
    # TODO: implement Deck.publish
    :ok
  end

  def unpublish(_record) do
    # TODO: implement Deck.unpublish
    :ok
  end

  def certify_tournament_legal(_record) do
    # TODO: implement Deck.certify_tournament_legal
    {:error, :not_implemented}
  end
end
