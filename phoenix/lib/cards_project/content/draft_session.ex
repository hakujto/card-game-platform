defmodule CardsProject.Content.DraftSession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "draft_sessions" do
    field :status, :string
    field :draft_type, :string
    field :seats, :integer, default: 8
    field :created_at, :naive_datetime
    field :completed_at, :naive_datetime
    belongs_to :card_set, CardsProject.Cards.CardSet
    belongs_to :participants, CardsProject.Content.DraftParticipant

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:seats, :created_at, :status, :draft_type, :completed_at, :card_set_id, :participants_id])
    |> validate_required([:seats, :created_at])
    |> validate_inclusion(:status, ["WaitingForPlayers", "Drafting", "Completed", "Abandoned"])
    |> validate_inclusion(:draft_type, ["Booster", "Cube", "Rochester"])
  end
end
