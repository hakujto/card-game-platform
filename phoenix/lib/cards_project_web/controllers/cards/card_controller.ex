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

  # POST /api/cards/{id}/ban
  def ban(conn, %{"id" => id}) do
    Cards.card_ban_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/cards/{id}/unban
  def unban(conn, %{"id" => id}) do
    Cards.card_unban_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/cards/{id}/restrict
  def restrict(conn, %{"id" => id}) do
    Cards.card_restrict_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/cards/{id}/unrestrict
  def unrestrict(conn, %{"id" => id}) do
    Cards.card_unrestrict_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/cards/{id}/value
  def calculate_value(conn, %{"id" => id}) do
    result = Cards.card_calculate_value_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/cards/{id}/rarity-bonus
  def apply_rarity_bonus(conn, %{"id" => id} = params) do
    multiplier = Map.get(params, "multiplier")
    result = Cards.card_apply_rarity_bonus_behavior(id, multiplier)
    json(conn, %{result: result})
  end

  # GET /api/cards/{id}/legal
  def is_legal_in_format(conn, %{"id" => id} = params) do
    format = Map.get(params, "format")
    result = Cards.card_is_legal_in_format_behavior(id, format)
    json(conn, %{result: result})
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
