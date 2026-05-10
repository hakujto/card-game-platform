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
    json(conn, serialize_friendship(friendship))
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

  def update(conn, %{"id" => id} = params) do
    friendship = Players.get_friendship!(id)
    case Players.update_friendship(friendship, params) do
      {:ok, friendship} ->
        json(conn, serialize_friendship(friendship))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    friendship = Players.get_friendship!(id)
    Players.delete_friendship(friendship)
    send_resp(conn, :no_content, "")
  end

  defp serialize_friendship(%Friendship{} = record) do
    Map.take(record, [:id, :status, :created_at, :requester_id, :receiver_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
