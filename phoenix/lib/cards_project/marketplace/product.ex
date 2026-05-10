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
end
