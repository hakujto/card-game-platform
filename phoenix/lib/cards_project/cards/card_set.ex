defmodule CardsProject.Cards.CardSet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "card_sets" do
    field :name, :string
    field :code, :string
    field :release_date, :date
    field :set_type, :string
    field :total_cards, :integer
    field :description, :string
    field :logo_url, :string

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :code, :release_date, :total_cards, :set_type, :description, :logo_url])
    |> validate_required([:name, :code, :release_date, :total_cards])
    |> validate_inclusion(:set_type, ["Core", "Expansion", "Supplemental", "Masters", "Draft"])
  end

  # ── Business operations ────────────────────────────────────────────

  def is_legal_in_standard(_record) do
    # TODO: implement CardSet.is_legal_in_standard
    {:error, :not_implemented}
  end
end
