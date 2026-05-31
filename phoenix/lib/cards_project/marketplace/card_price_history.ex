defmodule CardsProject.Marketplace.CardPriceHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "card_price_histories" do
    field :price_date, :date
    field :avg_price, :decimal
    field :min_price, :decimal
    field :max_price, :decimal
    field :volume, :integer
    field :foil, :boolean, default: false
    belongs_to :card, CardsProject.Cards.Card

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:price_date, :avg_price, :min_price, :max_price, :volume, :foil, :card_id])
    |> validate_required([:price_date, :avg_price, :min_price, :max_price, :volume, :foil])
    |> validate_number(:volume, greater_than_or_equal_to: 0, message: "Price history volume must not be negative")
    |> validate_number(:min_price, greater_than_or_equal_to: 0, message: "Prices must not be negative")
  end

  # ── Business operations ────────────────────────────────────────────

  def price_change_percent(_record, _previous_avg) do
    # TODO: implement CardPriceHistory.price_change_percent
    {:error, :not_implemented}
  end

  def is_price_spike(_record, _threshold_percent) do
    # TODO: implement CardPriceHistory.is_price_spike
    {:error, :not_implemented}
  end
end
