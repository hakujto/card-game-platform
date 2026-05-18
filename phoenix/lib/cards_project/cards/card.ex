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
    |> cast(attrs, [:name, :mana_cost, :description, :is_banned, :is_restricted, :power_level, :card_type, :rarity, :mana_colors, :attack, :defense, :loyalty, :flavor_text, :image_url, :artist_name, :legal_formats, :set_id])
    |> validate_required([:name, :mana_cost, :description, :is_banned, :is_restricted, :power_level])
    |> validate_inclusion(:card_type, ["Creature", "Spell", "Land", "Artifact", "Enchantment", "Planeswalker"])
    |> validate_inclusion(:rarity, ["Common", "Uncommon", "Rare", "MythicRare", "Legendary"])
    |> validate_inclusion(:mana_colors, ["White", "Blue", "Black", "Red", "Green", "Colorless"])
    |> validate_inclusion(:legal_formats, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
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
