defmodule CardsProject.Cards.CardRuling do
  use Ecto.Schema
  import Ecto.Changeset

  schema "card_rulings" do
    field :ruling_text, :string
    field :published_at, :date
    field :source, :string
    belongs_to :card, CardsProject.Cards.Card

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:ruling_text, :published_at, :source, :card_id])
    |> validate_required([:ruling_text, :published_at, :source])
  end

  # ── Business operations ────────────────────────────────────────────

  def is_current(_record) do
    # TODO: implement CardRuling.is_current
    {:error, :not_implemented}
  end

  def supersedes_previous(_record) do
    # TODO: implement CardRuling.supersedes_previous
    {:error, :not_implemented}
  end
end
