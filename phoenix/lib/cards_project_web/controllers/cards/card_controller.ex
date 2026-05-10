defmodule CardsProjectWeb.Cards.CardController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.Card

  def index(conn, _params) do
    cards = Cards.list_cards()
    json(conn, Enum.map(cards, &serialize_card/1))
  end

  def show(conn, %{"id" => id}) do
    card = Cards.get_card!(id)
    json(conn, serialize_card(card))
  end

  def create(conn, params) do
    case Cards.create_card(params) do
      {:ok, card} ->
        conn
        |> put_status(:created)
        |> json(serialize_card(card))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    card = Cards.get_card!(id)
    case Cards.update_card(card, params) do
      {:ok, card} ->
        json(conn, serialize_card(card))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    card = Cards.get_card!(id)
    Cards.delete_card(card)
    send_resp(conn, :no_content, "")
  end

  defp serialize_card(%Card{} = record) do
    Map.take(record, [:id, :name, :card_type, :rarity, :mana_cost, :mana_colors, :attack, :defense, :loyalty, :description, :flavor_text, :image_url, :artist_name, :legal_formats, :is_banned, :is_restricted, :power_level, :set_id, :rulings_id, :abilities_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
