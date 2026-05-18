defmodule CardsProjectWeb.Cards.DeckController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.Deck

  def index(conn, _params) do
    decks = Cards.list_decks()
    json(conn, Enum.map(decks, &serialize_deck/1))
  end

  def show(conn, %{"id" => id}) do
    deck = Cards.get_deck!(id)
    json(conn, serialize_deck(deck))
  end

  def create(conn, params) do
    case Cards.create_deck(params) do
      {:ok, deck} ->
        conn
        |> put_status(:created)
        |> json(serialize_deck(deck))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    deck = Cards.get_deck!(id)
    case Cards.update_deck(deck, params) do
      {:ok, deck} ->
        json(conn, serialize_deck(deck))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    deck = Cards.get_deck!(id)
    Cards.delete_deck(deck)
    send_resp(conn, :no_content, "")
  end

  # GET /api/decks/{id}/validate
  def validate_size(conn, %{"id" => id}) do
    result = Cards.deck_validate_size_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/decks/{id}/cards
  def add_card(conn, %{"id" => id} = params) do
    card_id = Map.get(params, "card_id")
    quantity = Map.get(params, "quantity")
    Cards.deck_add_card_behavior(id, card_id, quantity)
    send_resp(conn, :no_content, "")
  end

  # DELETE /api/decks/{id}/cards/{card_id}
  def remove_card(conn, %{"id" => id} = params) do
    card_id = Map.get(params, "card_id")
    Cards.deck_remove_card_behavior(id, card_id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/decks/{id}/win-rate
  def win_rate(conn, %{"id" => id}) do
    result = Cards.deck_win_rate_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/decks/{id}/clone
  def clone(conn, %{"id" => id}) do
    result = Cards.deck_clone_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/decks/{id}/publish
  def publish(conn, %{"id" => id}) do
    Cards.deck_publish_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/decks/{id}/unpublish
  def unpublish(conn, %{"id" => id}) do
    Cards.deck_unpublish_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/decks/{id}/certify
  def certify_tournament_legal(conn, %{"id" => id}) do
    result = Cards.deck_certify_tournament_legal_behavior(id)
    json(conn, %{result: result})
  end

  defp serialize_deck(%Deck{} = record) do
    Map.take(record, [:id, :name, :description, :format, :is_public, :is_tournament_legal, :archetype, :wins, :losses, :draws, :created_at, :updated_at, :player_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
