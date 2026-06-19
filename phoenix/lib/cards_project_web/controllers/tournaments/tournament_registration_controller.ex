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
    current_user_id = conn.assigns[:current_user] && conn.assigns[:current_user].id
    if tournament_registration.player_id != current_user_id do
      conn |> put_status(:forbidden) |> json(%{error: "You do not own this resource."}) |> halt()
    else
      json(conn, serialize_tournament_registration(tournament_registration))
    end
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

  # POST /api/registrations/{id}/withdraw
  def withdraw(conn, %{"id" => id}) do
    Tournaments.tournament_registration_withdraw_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/registrations/{id}/disqualify
  def disqualify(conn, %{"id" => id} = params) do
    reason = Map.get(params, "reason")
    Tournaments.tournament_registration_disqualify_behavior(id, reason)
    send_resp(conn, :no_content, "")
  end

  # POST /api/registrations/{id}/promote
  def promote_from_waitlist(conn, %{"id" => id}) do
    Tournaments.tournament_registration_promote_from_waitlist_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_tournament_registration(%TournamentRegistration{} = record) do
    record
    |> Map.take([:id, :status, :seed, :final_standing, :points_earned, :registered_at, :tournament_id, :player_id, :deck_id])
    |> (fn m -> Map.put(Map.delete(m, :registered_at), :registered_at, Map.get(m, :registered_at)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
