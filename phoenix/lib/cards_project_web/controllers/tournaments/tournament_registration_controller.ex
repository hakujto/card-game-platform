defmodule CardsProjectWeb.Tournaments.TournamentRegistrationController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.TournamentRegistration

  def index(conn, _params) do
    tournament_registrations = Tournaments.list_tournament_registrations()
    json(conn, Enum.map(tournament_registrations, &serialize_tournament_registration/1))
  end

  def show(conn, %{"id" => id}) do
    tournament_registration = Tournaments.get_tournament_registration!(id)
    json(conn, serialize_tournament_registration(tournament_registration))
  end

  def create(conn, params) do
    case Tournaments.create_tournament_registration(params) do
      {:ok, tournament_registration} ->
        conn
        |> put_status(:created)
        |> json(serialize_tournament_registration(tournament_registration))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    tournament_registration = Tournaments.get_tournament_registration!(id)
    case Tournaments.update_tournament_registration(tournament_registration, params) do
      {:ok, tournament_registration} ->
        json(conn, serialize_tournament_registration(tournament_registration))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    tournament_registration = Tournaments.get_tournament_registration!(id)
    Tournaments.delete_tournament_registration(tournament_registration)
    send_resp(conn, :no_content, "")
  end

  defp serialize_tournament_registration(%TournamentRegistration{} = record) do
    Map.take(record, [:id, :status, :seed, :final_standing, :points_earned, :registered_at, :tournament_id, :player_id, :deck_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
