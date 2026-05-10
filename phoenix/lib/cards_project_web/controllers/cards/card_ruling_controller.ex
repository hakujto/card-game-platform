defmodule CardsProjectWeb.Cards.CardRulingController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.CardRuling

  def index(conn, _params) do
    card_rulings = Cards.list_card_rulings()
    json(conn, Enum.map(card_rulings, &serialize_card_ruling/1))
  end

  def show(conn, %{"id" => id}) do
    card_ruling = Cards.get_card_ruling!(id)
    json(conn, serialize_card_ruling(card_ruling))
  end

  def create(conn, params) do
    case Cards.create_card_ruling(params) do
      {:ok, card_ruling} ->
        conn
        |> put_status(:created)
        |> json(serialize_card_ruling(card_ruling))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    card_ruling = Cards.get_card_ruling!(id)
    case Cards.update_card_ruling(card_ruling, params) do
      {:ok, card_ruling} ->
        json(conn, serialize_card_ruling(card_ruling))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    card_ruling = Cards.get_card_ruling!(id)
    Cards.delete_card_ruling(card_ruling)
    send_resp(conn, :no_content, "")
  end

  defp serialize_card_ruling(%CardRuling{} = record) do
    Map.take(record, [:id, :ruling_text, :published_at, :source, :card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
