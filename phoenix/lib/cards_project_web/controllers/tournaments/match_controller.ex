defmodule CardsProjectWeb.Tournaments.MatchController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.Match

  def index(conn, _params) do
    matches = Tournaments.list_matches()
    json(conn, Enum.map(matches, &serialize_match/1))
  end

  def show(conn, %{"id" => id}) do
    match = Tournaments.get_match!(id)
    json(conn, serialize_match(match))
  end

  def create(conn, params) do
    case Tournaments.create_match(params) do
      {:ok, match} ->
        conn
        |> put_status(:created)
        |> json(serialize_match(match))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    match = Tournaments.get_match!(id)
    case Tournaments.update_match(match, params) do
      {:ok, match} ->
        json(conn, serialize_match(match))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    match = Tournaments.get_match!(id)
    Tournaments.delete_match(match)
    send_resp(conn, :no_content, "")
  end

  defp serialize_match(%Match{} = record) do
    Map.take(record, [:id, :table_number, :status, :player1_wins, :player2_wins, :started_at, :ended_at, :result_notes, :round_id, :player1_id, :player2_id, :games_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
