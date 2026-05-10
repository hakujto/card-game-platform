defmodule CardsProjectWeb.Players.CraftingRecipeController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Players
  alias CardsProject.Players.CraftingRecipe

  def index(conn, _params) do
    crafting_recipes = Players.list_crafting_recipes()
    json(conn, Enum.map(crafting_recipes, &serialize_crafting_recipe/1))
  end

  def show(conn, %{"id" => id}) do
    crafting_recipe = Players.get_crafting_recipe!(id)
    json(conn, serialize_crafting_recipe(crafting_recipe))
  end

  def create(conn, params) do
    case Players.create_crafting_recipe(params) do
      {:ok, crafting_recipe} ->
        conn
        |> put_status(:created)
        |> json(serialize_crafting_recipe(crafting_recipe))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    crafting_recipe = Players.get_crafting_recipe!(id)
    case Players.update_crafting_recipe(crafting_recipe, params) do
      {:ok, crafting_recipe} ->
        json(conn, serialize_crafting_recipe(crafting_recipe))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    crafting_recipe = Players.get_crafting_recipe!(id)
    Players.delete_crafting_recipe(crafting_recipe)
    send_resp(conn, :no_content, "")
  end

  defp serialize_crafting_recipe(%CraftingRecipe{} = record) do
    Map.take(record, [:id, :dust_cost, :is_available, :result_card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
