defmodule CardsProject.Marketplace.TradeTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trade_transactions" do
    field :final_price, :decimal
    field :platform_fee, :decimal
    field :status, :string
    field :completed_at, :naive_datetime
    belongs_to :listing, CardsProject.Marketplace.TradeListing
    belongs_to :buyer, CardsProject.Players.Player
    belongs_to :seller, CardsProject.Players.Player

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:final_price, :platform_fee, :status, :completed_at, :listing_id, :buyer_id, :seller_id])
    |> validate_required([:final_price, :platform_fee])
    |> validate_inclusion(:status, ["Pending", "Completed", "Disputed", "Refunded"])
  end

  # ── Business operations ────────────────────────────────────────────

  def complete(_record) do
    # TODO: implement TradeTransaction.complete
    :ok
  end

  def refund(_record) do
    # TODO: implement TradeTransaction.refund
    :ok
  end

  def open_dispute(_record, _reason) do
    # TODO: implement TradeTransaction.open_dispute
    :ok
  end

  def seller_net(_record) do
    # TODO: implement TradeTransaction.seller_net
    {:error, :not_implemented}
  end
end
