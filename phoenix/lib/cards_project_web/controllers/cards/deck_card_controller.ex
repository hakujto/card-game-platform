defmodule CardsProjectWeb.Cards.DeckCardController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.DeckCard

  def index(conn, _params) do
    deck_cards = Cards.list_deck_cards()
    json(conn, Enum.map(deck_cards, &serialize_deck_card/1))
  end

  def show(conn, %{"id" => id}) do
    deck_card = Cards.get_deck_card!(id)
    json(conn, serialize_deck_card(deck_card))
  end

  def create(conn, params) do
    case Cards.create_deck_card(params) do
      {:ok, deck_card} ->
        conn
        |> put_status(:created)
        |> json(serialize_deck_card(deck_card))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    deck_card = Cards.get_deck_card!(id)
    case Cards.update_deck_card(deck_card, params) do
      {:ok, deck_card} ->
        json(conn, serialize_deck_card(deck_card))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    deck_card = Cards.get_deck_card!(id)
    Cards.delete_deck_card(deck_card)
    send_resp(conn, :no_content, "")
  end

  defp serialize_deck_card(%DeckCard{} = record) do
    Map.take(record, [:id, :quantity, :is_commander, :deck_id, :card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
