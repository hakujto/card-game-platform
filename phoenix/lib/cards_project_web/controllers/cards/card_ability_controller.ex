defmodule CardsProjectWeb.Cards.CardAbilityController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Cards
  alias CardsProject.Cards.CardAbility

  def index(conn, _params) do
    card_abilities = Cards.list_card_abilities()
    json(conn, Enum.map(card_abilities, &serialize_card_ability/1))
  end

  def show(conn, %{"id" => id}) do
    card_ability = Cards.get_card_ability!(id)
    json(conn, serialize_card_ability(card_ability))
  end

  def create(conn, params) do
    case Cards.create_card_ability(params) do
      {:ok, card_ability} ->
        conn
        |> put_status(:created)
        |> json(serialize_card_ability(card_ability))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    card_ability = Cards.get_card_ability!(id)
    case Cards.update_card_ability(card_ability, params) do
      {:ok, card_ability} ->
        json(conn, serialize_card_ability(card_ability))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    card_ability = Cards.get_card_ability!(id)
    Cards.delete_card_ability(card_ability)
    send_resp(conn, :no_content, "")
  end

  defp serialize_card_ability(%CardAbility{} = record) do
    Map.take(record, [:id, :ability_type, :keyword, :ability_text, :timing, :card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
