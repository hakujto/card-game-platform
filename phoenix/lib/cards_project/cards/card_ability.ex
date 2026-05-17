defmodule CardsProject.Cards.CardAbility do
  use Ecto.Schema
  import Ecto.Changeset

  schema "card_abilities" do
    field :ability_type, :string
    field :keyword, :string
    field :ability_text, :string
    field :timing, :string
    belongs_to :card, CardsProject.Cards.Card

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:ability_text, :ability_type, :keyword, :timing, :card_id])
    |> validate_required([:ability_text])
    |> validate_inclusion(:ability_type, ["Keyword", "Activated", "Triggered", "Static"])
    |> validate_inclusion(:timing, ["Any", "Sorcery", "Instant", "Combat"])
  end

  # ── Business operations ────────────────────────────────────────────

  def is_usable_at(_record, _timing) do
    # TODO: implement CardAbility.is_usable_at
    {:error, :not_implemented}
  end

  def describe(_record) do
    # TODO: implement CardAbility.describe
    {:error, :not_implemented}
  end
end
