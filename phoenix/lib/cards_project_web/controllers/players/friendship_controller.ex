defmodule CardsProjectWeb.Players.FriendshipController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Players
  alias CardsProject.Players.Friendship

  def index(conn, _params) do
    friendships = Players.list_friendships()
    json(conn, Enum.map(friendships, &serialize_friendship/1))
  end

  def show(conn, %{"id" => id}) do
    friendship = Players.get_friendship!(id)
    current_user_id = conn.assigns[:current_user] && conn.assigns[:current_user].id
    if friendship.requester_id != current_user_id do
      conn |> put_status(:forbidden) |> json(%{error: "You do not own this resource."}) |> halt()
    else
      json(conn, serialize_friendship(friendship))
    end
  end

  def create(conn, params) do
    case Players.create_friendship(params) do
      {:ok, friendship} ->
        conn
        |> put_status(:created)
        |> json(serialize_friendship(friendship))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    friendship = Players.get_friendship!(id)
    current_user_id = conn.assigns[:current_user] && conn.assigns[:current_user].id
    if friendship.requester_id != current_user_id do
      conn |> put_status(:forbidden) |> json(%{error: "You do not own this resource."}) |> halt()
    else
      Players.delete_friendship(friendship)
      send_resp(conn, :no_content, "")
    end
  end

  # POST /api/friendships/{id}/accept
  def accept(conn, %{"id" => id}) do
    Players.friendship_accept_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/friendships/{id}/decline
  def decline(conn, %{"id" => id}) do
    Players.friendship_decline_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/friendships/{id}/block
  def block(conn, %{"id" => id}) do
    Players.friendship_block_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_friendship(%Friendship{} = record) do
    record
    |> Map.take([:id, :status, :created_at, :requester_id, :receiver_id])
    |> (fn m -> Map.put(Map.delete(m, :created_at), :created_at, Map.get(m, :created_at)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
