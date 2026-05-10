defmodule CardsProject.Players.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friendships" do
    field :status, :string
    field :created_at, :naive_datetime
    belongs_to :requester, CardsProject.Players.Player
    belongs_to :receiver, CardsProject.Players.Player

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:created_at, :status, :requester_id, :receiver_id])
    |> validate_required([:created_at])
    |> validate_inclusion(:status, ["Pending", "Accepted", "Blocked"])
  end
end
