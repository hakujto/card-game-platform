defmodule CardsProject.Marketplace.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :product_type, :string
    field :price, :decimal
    field :stock, :integer, default: 0
    field :active, :boolean, default: true
    field :discount_percent, :integer, default: 0
    field :description, :string
    field :image_url, :string
    field :featured, :boolean, default: false
    belongs_to :card, CardsProject.Cards.Card
    belongs_to :card_set, CardsProject.Cards.CardSet

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :price, :stock, :active, :discount_percent, :featured, :product_type, :description, :image_url, :card_id, :card_set_id])
    |> validate_required([:name, :price, :stock, :active, :discount_percent, :featured])
    |> validate_inclusion(:product_type, ["SingleCard", "BoosterPack", "Bundle", "PreconstructedDeck", "Accessory"])
  end

  # ── Business operations ────────────────────────────────────────────

  def activate(_record) do
    # TODO: implement Product.activate
    :ok
  end

  def deactivate(_record) do
    # TODO: implement Product.deactivate
    :ok
  end

  def apply_discount(_record, _percent) do
    # TODO: implement Product.apply_discount
    {:error, :not_implemented}
  end

  def restock(_record, _quantity) do
    # TODO: implement Product.restock
    :ok
  end

  def effective_price(_record) do
    # TODO: implement Product.effective_price
    {:error, :not_implemented}
  end

  def is_in_stock(_record) do
    # TODO: implement Product.is_in_stock
    {:error, :not_implemented}
  end
end
