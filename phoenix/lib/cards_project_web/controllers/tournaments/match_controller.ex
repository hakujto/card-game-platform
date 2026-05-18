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

  # POST /api/matches/{id}/record
  def record_result(conn, %{"id" => id} = params) do
    p1_wins = Map.get(params, "p1_wins")
    p2_wins = Map.get(params, "p2_wins")
    Tournaments.match_record_result_behavior(id, p1_wins, p2_wins)
    send_resp(conn, :no_content, "")
  end

  # GET /api/matches/{id}/winner
  def determine_winner(conn, %{"id" => id}) do
    result = Tournaments.match_determine_winner_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/matches/{id}/concede
  def concede(conn, %{"id" => id} = params) do
    player_id = Map.get(params, "player_id")
    Tournaments.match_concede_behavior(id, player_id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/matches/{id}/draw
  def draw(conn, %{"id" => id}) do
    Tournaments.match_draw_behavior(id)
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
