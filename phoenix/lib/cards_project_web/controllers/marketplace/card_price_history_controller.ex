defmodule CardsProjectWeb.Marketplace.CardPriceHistoryController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.CardPriceHistory

  def index(conn, _params) do
    card_price_histories = Marketplace.list_card_price_histories()
    json(conn, Enum.map(card_price_histories, &serialize_card_price_history/1))
  end

  def show(conn, %{"id" => id}) do
    card_price_history = Marketplace.get_card_price_history!(id)
    json(conn, serialize_card_price_history(card_price_history))
  end

  def create(conn, params) do
    case Marketplace.create_card_price_history(params) do
      {:ok, card_price_history} ->
        conn
        |> put_status(:created)
        |> json(serialize_card_price_history(card_price_history))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    card_price_history = Marketplace.get_card_price_history!(id)
    case Marketplace.update_card_price_history(card_price_history, params) do
      {:ok, card_price_history} ->
        json(conn, serialize_card_price_history(card_price_history))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    card_price_history = Marketplace.get_card_price_history!(id)
    Marketplace.delete_card_price_history(card_price_history)
    send_resp(conn, :no_content, "")
  end

  defp serialize_card_price_history(%CardPriceHistory{} = record) do
    Map.take(record, [:id, :price_date, :avg_price, :min_price, :max_price, :volume, :foil, :card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
