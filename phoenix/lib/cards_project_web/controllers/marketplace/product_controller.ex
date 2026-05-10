defmodule CardsProjectWeb.Marketplace.ProductController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.Product

  def index(conn, _params) do
    products = Marketplace.list_products()
    json(conn, Enum.map(products, &serialize_product/1))
  end

  def show(conn, %{"id" => id}) do
    product = Marketplace.get_product!(id)
    json(conn, serialize_product(product))
  end

  def create(conn, params) do
    case Marketplace.create_product(params) do
      {:ok, product} ->
        conn
        |> put_status(:created)
        |> json(serialize_product(product))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    product = Marketplace.get_product!(id)
    case Marketplace.update_product(product, params) do
      {:ok, product} ->
        json(conn, serialize_product(product))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Marketplace.get_product!(id)
    Marketplace.delete_product(product)
    send_resp(conn, :no_content, "")
  end

  defp serialize_product(%Product{} = record) do
    Map.take(record, [:id, :name, :product_type, :price, :stock, :active, :discount_percent, :description, :image_url, :featured, :card_id, :card_set_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
