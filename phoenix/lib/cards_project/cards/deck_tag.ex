defmodule CardsProject.Cards.DeckTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deck_tags" do
    field :name, :string
    field :color, :string

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :color])
    |> validate_required([:name])
  end
end
