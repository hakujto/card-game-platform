defmodule CardsProjectWeb.Cards.DeckSideboardCardController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.DeckSideboardCard

  def index(conn, _params) do
    deck_sideboard_cards = Cards.list_deck_sideboard_cards()
    json(conn, Enum.map(deck_sideboard_cards, &serialize_deck_sideboard_card/1))
  end

  def show(conn, %{"id" => id}) do
    deck_sideboard_card = Cards.get_deck_sideboard_card!(id)
    json(conn, serialize_deck_sideboard_card(deck_sideboard_card))
  end

  def create(conn, params) do
    case Cards.create_deck_sideboard_card(params) do
      {:ok, deck_sideboard_card} ->
        conn
        |> put_status(:created)
        |> json(serialize_deck_sideboard_card(deck_sideboard_card))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    deck_sideboard_card = Cards.get_deck_sideboard_card!(id)
    case Cards.update_deck_sideboard_card(deck_sideboard_card, params) do
      {:ok, deck_sideboard_card} ->
        json(conn, serialize_deck_sideboard_card(deck_sideboard_card))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    deck_sideboard_card = Cards.get_deck_sideboard_card!(id)
    Cards.delete_deck_sideboard_card(deck_sideboard_card)
    send_resp(conn, :no_content, "")
  end

  defp serialize_deck_sideboard_card(%DeckSideboardCard{} = record) do
    Map.take(record, [:id, :quantity, :deck_id, :card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
