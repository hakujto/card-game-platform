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

  # GET /api/card-sets/{id}/standard-legal
  def is_legal_in_standard(conn, %{"id" => id}) do
    result = Cards.card_set_is_legal_in_standard_behavior(id)
    json(conn, %{result: result})
  end

  # GET /api/card-sets/{id}/legal
  def is_legal_in_format(conn, %{"id" => id} = params) do
    format = Map.get(params, "format")
    result = Cards.card_set_is_legal_in_format_behavior(id, format)
    json(conn, %{result: result})
  end

  # GET /api/card-sets/{id}/rarity-count
  def card_count_by_rarity(conn, %{"id" => id} = params) do
    rarity = Map.get(params, "rarity")
    result = Cards.card_set_card_count_by_rarity_behavior(id, rarity)
    json(conn, %{result: result})
  end

  # POST /api/card-sets/{id}/rotate
  def rotate_out(conn, %{"id" => id}) do
    Cards.card_set_rotate_out_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_card_set(%CardSet{} = record) do
    Map.take(record, [:id, :name, :code, :release_date, :rotation_date, :set_type, :total_cards, :is_rotated, :description, :logo_url])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
