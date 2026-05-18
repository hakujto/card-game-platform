defmodule CardsProjectWeb.Tournaments.AwardedPrizeController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.AwardedPrize

  def index(conn, _params) do
    awarded_prizes = Tournaments.list_awarded_prizes()
    json(conn, Enum.map(awarded_prizes, &serialize_awarded_prize/1))
  end

  def show(conn, %{"id" => id}) do
    awarded_prize = Tournaments.get_awarded_prize!(id)
    json(conn, serialize_awarded_prize(awarded_prize))
  end

  def create(conn, params) do
    case Tournaments.create_awarded_prize(params) do
      {:ok, awarded_prize} ->
        conn
        |> put_status(:created)
        |> json(serialize_awarded_prize(awarded_prize))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    awarded_prize = Tournaments.get_awarded_prize!(id)
    case Tournaments.update_awarded_prize(awarded_prize, params) do
      {:ok, awarded_prize} ->
        json(conn, serialize_awarded_prize(awarded_prize))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    awarded_prize = Tournaments.get_awarded_prize!(id)
    Tournaments.delete_awarded_prize(awarded_prize)
    send_resp(conn, :no_content, "")
  end

  # POST /api/awarded-prizes/{id}/claim
  def claim(conn, %{"id" => id}) do
    Tournaments.awarded_prize_claim_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_awarded_prize(%AwardedPrize{} = record) do
    Map.take(record, [:id, :final_placement, :awarded_at, :claimed, :claimed_at, :prize_id, :player_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
