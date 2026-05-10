defmodule CardsProject.Marketplace.Tradelisting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tradelistings" do
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
    |> cast(attrs, [:foil, :quantity, :created_at, :listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :condition, :status, :description, :expires_at, :seller_id, :card_id, :bids_id])
    |> validate_required([:foil, :quantity, :created_at])
    |> validate_inclusion(:listing_type, ["FixedPrice", "Auction", "TradeOffer"])
    |> validate_inclusion(:condition, ["Mint", "NearMint", "Excellent", "Good", "Played"])
    |> validate_inclusion(:status, ["Active", "Sold", "Expired", "Cancelled", "Pending"])
  end
end
