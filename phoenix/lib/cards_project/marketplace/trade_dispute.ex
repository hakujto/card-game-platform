defmodule CardsProject.Marketplace.TradeDispute do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trade_disputes" do
    field :status, :string
    field :reason, :string
    field :description, :string
    field :resolution, :string
    field :opened_at, :naive_datetime
    field :resolved_at, :naive_datetime
    belongs_to :transaction, CardsProject.Marketplace.TradeTransaction
    belongs_to :opened_by, CardsProject.Players.Player
    belongs_to :resolved_by, CardsProject.Players.Player

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:description, :opened_at, :status, :reason, :resolution, :resolved_at, :transaction_id, :opened_by_id, :resolved_by_id])
    |> validate_required([:description, :opened_at])
    |> validate_inclusion(:status, ["Open", "UnderReview", "Resolved", "Escalated"])
    |> validate_inclusion(:reason, ["ItemNotReceived", "ItemNotAsDescribed", "FraudSuspected", "Other"])
  end

  # ── Business operations ────────────────────────────────────────────

  def escalate(_record) do
    # TODO: implement TradeDispute.escalate
    :ok
  end

  def resolve(_record, _resolution_text) do
    # TODO: implement TradeDispute.resolve
    :ok
  end

  def close_resolved(_record) do
    # TODO: implement TradeDispute.close_resolved
    :ok
  end

  def review(_record) do
    # TODO: implement TradeDispute.review
    :ok
  end

  # ── Lifecycle state machine ─────────────────────────────────────────
  @allowed_transitions %{
    "Open" => ["UnderReview"],
    "UnderReview" => ["Resolved", "Escalated"],
    "Escalated" => ["Resolved"]
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
