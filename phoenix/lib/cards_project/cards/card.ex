defmodule CardsProject.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :name, :string
    field :card_type, :string
    field :rarity, :string
    field :mana_cost, :integer, default: 0
    field :mana_colors, :string
    field :attack, :integer
    field :defense, :integer
    field :loyalty, :integer
    field :description, :string
    field :flavor_text, :string
    field :image_url, :string
    field :artist_name, :string
    field :legal_formats, :string
    field :is_banned, :boolean, default: false
    field :is_restricted, :boolean, default: false
    field :power_level, :integer, default: 1
    belongs_to :set, CardsProject.Cards.CardSet
    has_many :rulings, CardsProject.Cards.CardRuling, foreign_key: :card_id
    has_many :abilities, CardsProject.Cards.CardAbility, foreign_key: :card_id
    many_to_many :decks, CardsProject.Cards.Deck, join_through: "deck_cards"
    many_to_many :sideboard_decks, CardsProject.Cards.Deck, join_through: "deck_sideboard_cards"
    has_many :deck_cards, CardsProject.Cards.DeckCard, foreign_key: :card_id
    has_many :player_collections, CardsProject.Players.PlayerCollection, foreign_key: :card_id
    has_many :crafting_recipes, CardsProject.Players.CraftingRecipe, foreign_key: :result_card_id
    has_many :used_in_recipes, CardsProject.Players.CraftingIngredient, foreign_key: :card_id
    has_one :shop_product, CardsProject.Marketplace.Product, foreign_key: :card_id
    has_many :trade_listings, CardsProject.Marketplace.TradeListing, foreign_key: :card_id
    has_many :price_history, CardsProject.Marketplace.CardPriceHistory, foreign_key: :card_id
    has_many :draft_picks, CardsProject.Content.DraftPick, foreign_key: :card_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :mana_cost, :description, :is_banned, :is_restricted, :power_level, :card_type, :rarity, :mana_colors, :attack, :defense, :loyalty, :flavor_text, :image_url, :artist_name, :legal_formats, :set_id])
    |> validate_required([:name, :mana_cost, :description, :is_banned, :is_restricted, :power_level])
    |> validate_inclusion(:card_type, ["Creature", "Spell", "Land", "Artifact", "Enchantment", "Planeswalker"])
    |> validate_inclusion(:rarity, ["Common", "Uncommon", "Rare", "MythicRare", "Legendary"])
    |> validate_inclusion(:mana_colors, ["White", "Blue", "Black", "Red", "Green", "Colorless"])
    |> validate_inclusion(:legal_formats, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
    |> validate_number(:mana_cost, greater_than_or_equal_to: 0, less_than_or_equal_to: 20, message: "mana_cost must be between 0 and 20")
    |> validate_number(:power_level, greater_than_or_equal_to: 1, less_than_or_equal_to: 10, message: "power_level must be between 1 and 10")
    |> then(fn cs ->
      if get_field(cs, :card_type) == "Creature" and (is_nil(get_field(cs, :attack)) or is_nil(get_field(cs, :defense))) do
        Ecto.Changeset.add_error(cs, :attack, "Creature card must have attack and defense")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :card_type) == "Planeswalker" and (is_nil(get_field(cs, :loyalty))) do
        Ecto.Changeset.add_error(cs, :loyalty, "Planeswalker card must have loyalty")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :card_type) == "Land" and (get_field(cs, :mana_cost) != "0") do
        Ecto.Changeset.add_error(cs, :mana_cost, "Land card must have zero mana cost")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :card_type) != "Planeswalker" and (not is_nil(get_field(cs, :loyalty))) do
        Ecto.Changeset.add_error(cs, :loyalty, "Only Planeswalker cards can have loyalty")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :is_banned) == "true" and (get_field(cs, :legal_formats) != "message") do
        Ecto.Changeset.add_error(cs, :legal_formats, "banned_card_not_in_legal_formats validation failed")
      else
        cs
      end
    end)
  end

  # ── Business operations ────────────────────────────────────────────

  def ban(_record) do
    # TODO: implement Card.ban
    :ok
  end

  def unban(_record) do
    # TODO: implement Card.unban
    :ok
  end

  def restrict(_record) do
    # TODO: implement Card.restrict
    :ok
  end

  def unrestrict(_record) do
    # TODO: implement Card.unrestrict
    :ok
  end

  def calculate_value(_record) do
    # TODO: implement Card.calculate_value
    {:error, :not_implemented}
  end

  def apply_rarity_bonus(_record, _multiplier) do
    # TODO: implement Card.apply_rarity_bonus
    {:error, :not_implemented}
  end

  def is_legal_in_format(_record, _format) do
    # TODO: implement Card.is_legal_in_format
    {:error, :not_implemented}
  end
end
