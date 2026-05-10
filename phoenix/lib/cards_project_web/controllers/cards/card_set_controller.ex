defmodule CardsProjectWeb.Cards.CardSetController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.CardSet

  def index(conn, _params) do
    card_sets = Cards.list_card_sets()
    json(conn, Enum.map(card_sets, &serialize_card_set/1))
  end

  def show(conn, %{"id" => id}) do
    card_set = Cards.get_card_set!(id)
    json(conn, serialize_card_set(card_set))
  end

  def create(conn, params) do
    case Cards.create_card_set(params) do
      {:ok, card_set} ->
        conn
        |> put_status(:created)
        |> json(serialize_card_set(card_set))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    card_set = Cards.get_card_set!(id)
    case Cards.update_card_set(card_set, params) do
      {:ok, card_set} ->
        json(conn, serialize_card_set(card_set))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    card_set = Cards.get_card_set!(id)
    Cards.delete_card_set(card_set)
    send_resp(conn, :no_content, "")
  end

  defp serialize_card_set(%CardSet{} = record) do
    Map.take(record, [:id, :name, :code, :release_date, :set_type, :total_cards, :description, :logo_url])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
