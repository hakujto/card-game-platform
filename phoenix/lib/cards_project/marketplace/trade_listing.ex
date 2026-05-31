defmodule CardsProject.Marketplace.TradeListing do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trade_listings" do
    field :status, :string
    field :listing_type, :string
    field :asking_price, :decimal
    field :auction_start_price, :decimal
    field :auction_current_bid, :decimal
    field :auction_end_time, :naive_datetime
    field :foil, :boolean, default: false
    field :condition, :string
    field :quantity, :integer, default: 1
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
    |> cast(attrs, [:foil, :quantity, :created_at, :status, :listing_type, :asking_price, :auction_start_price, :auction_current_bid, :auction_end_time, :condition, :description, :expires_at, :seller_id, :card_id])
    |> validate_required([:foil, :quantity, :created_at])
    |> validate_inclusion(:status, ["Active", "Sold", "Expired", "Cancelled", "Pending"])
    |> validate_inclusion(:listing_type, ["FixedPrice", "Auction", "TradeOffer"])
    |> validate_inclusion(:condition, ["Mint", "NearMint", "Excellent", "Good", "Played"])
    |> validate_number(:quantity, greater_than_or_equal_to: 1, less_than_or_equal_to: 9999, message: "Listing quantity must be between 1 and 9999")
    |> then(fn cs ->
      if get_field(cs, :listing_type) == "FixedPrice" and (is_nil(get_field(cs, :asking_price))) do
        Ecto.Changeset.add_error(cs, :asking_price, "Fixed price listing must have an asking price")
      else
        cs
      end
    end)
    |> then(fn cs ->
      if get_field(cs, :listing_type) == "Auction" and (is_nil(get_field(cs, :auction_start_price)) or is_nil(get_field(cs, :auction_end_time))) do
        Ecto.Changeset.add_error(cs, :auction_start_price, "Auction listing must have a start price and end time")
      else
        cs
      end
    end)
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

  # ── Lifecycle state machine ─────────────────────────────────────────
  @allowed_transitions %{
    "Pending" => ["Active"],
    "Active" => ["Sold", "Expired", "Cancelled"]
  }

  def assert_transition(%__MODULE__{status: current}, to) do
    allowed = Map.get(@allowed_transitions, current, [])
    if to in allowed do
      :ok
    else
      {:error, "Transition #{current} -> #{to} not allowed"}
    end
  end
end
