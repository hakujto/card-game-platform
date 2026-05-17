defmodule CardsProject.Marketplace.TradeBid do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trade_bids" do
    field :amount, :decimal
    field :placed_at, :naive_datetime
    field :is_winning, :boolean, default: false
    belongs_to :listing, CardsProject.Marketplace.Tradelisting
    belongs_to :bidder, CardsProject.Players.Player

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:amount, :placed_at, :is_winning, :listing_id, :bidder_id])
    |> validate_required([:amount, :placed_at, :is_winning])
  end

  # ── Business operations ────────────────────────────────────────────

  def outbid_by(_record, _new_amount) do
    # TODO: implement TradeBid.outbid_by
    {:error, :not_implemented}
  end
end
