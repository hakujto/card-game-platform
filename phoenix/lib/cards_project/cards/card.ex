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
    belongs_to :rulings, CardsProject.Cards.CardRuling
    belongs_to :abilities, CardsProject.Cards.CardAbility

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :mana_cost, :description, :is_banned, :is_restricted, :power_level, :card_type, :rarity, :mana_colors, :attack, :defense, :loyalty, :flavor_text, :image_url, :artist_name, :legal_formats, :set_id, :rulings_id, :abilities_id])
    |> validate_required([:name, :mana_cost, :description, :is_banned, :is_restricted, :power_level])
    |> validate_inclusion(:card_type, ["Creature", "Spell", "Land", "Artifact", "Enchantment", "Planeswalker"])
    |> validate_inclusion(:rarity, ["Common", "Uncommon", "Rare", "MythicRare", "Legendary"])
    |> validate_inclusion(:mana_colors, ["White", "Blue", "Black", "Red", "Green", "Colorless"])
    |> validate_inclusion(:legal_formats, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
  end
end
