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
end
