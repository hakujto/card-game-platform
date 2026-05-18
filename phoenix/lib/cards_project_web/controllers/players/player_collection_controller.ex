defmodule CardsProjectWeb.Players.PlayerCollectionController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Players
  alias CardsProject.Players.PlayerCollection

  def index(conn, _params) do
    player_collections = Players.list_player_collections()
    json(conn, Enum.map(player_collections, &serialize_player_collection/1))
  end

  def show(conn, %{"id" => id}) do
    player_collection = Players.get_player_collection!(id)
    json(conn, serialize_player_collection(player_collection))
  end

  def create(conn, params) do
    case Players.create_player_collection(params) do
      {:ok, player_collection} ->
        conn
        |> put_status(:created)
        |> json(serialize_player_collection(player_collection))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    player_collection = Players.get_player_collection!(id)
    case Players.update_player_collection(player_collection, params) do
      {:ok, player_collection} ->
        json(conn, serialize_player_collection(player_collection))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    player_collection = Players.get_player_collection!(id)
    Players.delete_player_collection(player_collection)
    send_resp(conn, :no_content, "")
  end

  # POST /api/collection/{id}/add
  def add(conn, %{"id" => id} = params) do
    quantity = Map.get(params, "quantity")
    Players.player_collection_add_behavior(id, quantity)
    send_resp(conn, :no_content, "")
  end

  # POST /api/collection/{id}/remove
  def remove(conn, %{"id" => id} = params) do
    quantity = Map.get(params, "quantity")
    Players.player_collection_remove_behavior(id, quantity)
    send_resp(conn, :no_content, "")
  end

  # GET /api/collection/{id}/value
  def estimated_value(conn, %{"id" => id}) do
    result = Players.player_collection_estimated_value_behavior(id)
    json(conn, %{result: result})
  end

  defp serialize_player_collection(%PlayerCollection{} = record) do
    Map.take(record, [:id, :quantity, :foil, :condition, :acquired_at, :acquired_via, :player_id, :card_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
