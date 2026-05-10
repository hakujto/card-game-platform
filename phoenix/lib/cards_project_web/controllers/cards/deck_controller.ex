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

  defp serialize_deck(%Deck{} = record) do
    Map.take(record, [:id, :name, :description, :format, :is_public, :is_tournament_legal, :archetype, :wins, :losses, :created_at, :updated_at, :player_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
