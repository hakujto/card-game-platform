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

  # ── Business operations ────────────────────────────────────────────

  def rename(_record, _new_name) do
    # TODO: implement DeckTag.rename
    :ok
  end

  def merge_into(_record, _target_tag_id) do
    # TODO: implement DeckTag.merge_into
    :ok
  end
end
