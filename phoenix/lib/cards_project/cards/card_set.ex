defmodule CardsProject.Cards.CardSet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "card_sets" do
    field :name, :string
    field :code, :string
    field :release_date, :date
    field :rotation_date, :date
    field :set_type, :string
    field :total_cards, :integer
    field :is_rotated, :boolean, default: false
    field :description, :string
    field :logo_url, :string
    has_many :cards, CardsProject.Cards.Card, foreign_key: :set_id
    has_many :shop_products, CardsProject.Marketplace.Product, foreign_key: :card_set_id
    has_many :draft_sessions, CardsProject.Content.DraftSession, foreign_key: :card_set_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :code, :release_date, :total_cards, :is_rotated, :rotation_date, :set_type, :description, :logo_url])
    |> validate_required([:name, :code, :release_date, :total_cards, :is_rotated])
    |> validate_inclusion(:set_type, ["Core", "Expansion", "Supplemental", "Masters", "Draft"])
    |> unique_constraint(:code, message: "code must be unique")
    |> validate_number(:total_cards, greater_than: 0, message: "Card set must have at least one card")
    |> then(fn cs ->
      if not is_nil(get_field(cs, :rotation_date)) and (not ((get_field(cs, :rotation_date) || 0) > get_field(cs, :release_date))) do
        Ecto.Changeset.add_error(cs, :rotation_date, "Rotation date must be after release date")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :is_rotated) == "true" and (is_nil(get_field(cs, :rotation_date))) do
        Ecto.Changeset.add_error(cs, :rotation_date, "Rotated set must have a rotation date")
      else
        cs
      end
    end)
  end

  # ── Business operations ────────────────────────────────────────────

  def is_legal_in_standard(_record) do
    # TODO: implement CardSet.is_legal_in_standard
    {:error, :not_implemented}
  end

  def is_legal_in_format(_record, _format) do
    # TODO: implement CardSet.is_legal_in_format
    {:error, :not_implemented}
  end

  def card_count_by_rarity(_record, _rarity) do
    # TODO: implement CardSet.card_count_by_rarity
    {:error, :not_implemented}
  end

  def rotate_out(_record) do
    # TODO: implement CardSet.rotate_out
    :ok
  end
end
