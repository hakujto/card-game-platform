defmodule CardsProjectWeb.Tournaments.TournamentJudgeController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.TournamentJudge

  def index(conn, _params) do
    tournament_judges = Tournaments.list_tournament_judges()
    json(conn, Enum.map(tournament_judges, &serialize_tournament_judge/1))
  end

  def show(conn, %{"id" => id}) do
    tournament_judge = Tournaments.get_tournament_judge!(id)
    json(conn, serialize_tournament_judge(tournament_judge))
  end

  def create(conn, params) do
    case Tournaments.create_tournament_judge(params) do
      {:ok, tournament_judge} ->
        conn
        |> put_status(:created)
        |> json(serialize_tournament_judge(tournament_judge))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    tournament_judge = Tournaments.get_tournament_judge!(id)
    case Tournaments.update_tournament_judge(tournament_judge, params) do
      {:ok, tournament_judge} ->
        json(conn, serialize_tournament_judge(tournament_judge))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    tournament_judge = Tournaments.get_tournament_judge!(id)
    Tournaments.delete_tournament_judge(tournament_judge)
    send_resp(conn, :no_content, "")
  end

  defp serialize_tournament_judge(%TournamentJudge{} = record) do
    Map.take(record, [:id, :role, :tournament_id, :player_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
