defmodule CardsProject.Marketplace.TradeListing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trade_listings" do
    field :listing_type, :string
    field :asking_price, :decimal
    field :auction_start_price, :decimal
    field :auction_current_bid, :decimal
    field :auction_end_time, :naive_datetime
    field :foil, :boolean, default: false
    field :condition, :string
    field :quantity, :integer, default: 1
    field :status, :string
    field :description, :string
    field :created_at, :naive_datetime
    field :expires_at, :naive_datetime
    belongs_to :seller, CardsProject.Players.Player
    belongs_to :card, CardsProject.Cards.Card
    belongs_to :bids, CardsProject.Marketplace.TradeBid

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:foil, :quantity, :created_at, :listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :condition, :status, :description, :expires_at, :seller_id, :card_id])
    |> validate_required([:foil, :quantity, :created_at])
    |> validate_inclusion(:listing_type, ["FixedPrice", "Auction", "TradeOffer"])
    |> validate_inclusion(:condition, ["Mint", "NearMint", "Excellent", "Good", "Played"])
    |> validate_inclusion(:status, ["Active", "Sold", "Expired", "Cancelled", "Pending"])
  end

  # ── Business operations ────────────────────────────────────────────

  def close(_record) do
    # TODO: implement TradeListing.close
    :ok
  end

  def extend(_record, _days) do
    # TODO: implement TradeListing.extend
    :ok
  end

  def cancel(_record) do
    # TODO: implement TradeListing.cancel
    :ok
  end

  def is_expired(_record) do
    # TODO: implement TradeListing.is_expired
    {:error, :not_implemented}
  end

  def finalize_auction(_record) do
    # TODO: implement TradeListing.finalize_auction
    :ok
  end
end
