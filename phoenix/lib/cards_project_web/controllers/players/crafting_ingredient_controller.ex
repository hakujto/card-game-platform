defmodule CardsProjectWeb.Players.CraftingIngredientController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Players
  alias CardsProject.Players.CraftingIngredient

  def index(conn, _params) do
    crafting_ingredients = Players.list_crafting_ingredients()
    json(conn, Enum.map(crafting_ingredients, &serialize_crafting_ingredient/1))
  end

  def show(conn, %{"id" => id}) do
    crafting_ingredient = Players.get_crafting_ingredient!(id)
    json(conn, serialize_crafting_ingredient(crafting_ingredient))
  end

  def create(conn, params) do
    case Players.create_crafting_ingredient(params) do
      {:ok, crafting_ingredient} ->
        conn
        |> put_status(:created)
        |> json(serialize_crafting_ingredient(crafting_ingredient))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    crafting_ingredient = Players.get_crafting_ingredient!(id)
    case Players.update_crafting_ingredient(crafting_ingredient, params) do
      {:ok, crafting_ingredient} ->
        json(conn, serialize_crafting_ingredient(crafting_ingredient))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    crafting_ingredient = Players.get_crafting_ingredient!(id)
    Players.delete_crafting_ingredient(crafting_ingredient)
    send_resp(conn, :no_content, "")
  end

  defp serialize_crafting_ingredient(%CraftingIngredient{} = record) do
    Map.take(record, [:id, :quantity, :recipe_id, :card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
