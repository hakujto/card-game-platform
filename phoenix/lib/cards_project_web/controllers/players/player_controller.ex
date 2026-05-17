defmodule CardsProjectWeb.Players.PlayerController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Players
  alias CardsProject.Players.Player

  def index(conn, _params) do
    players = Players.list_players()
    json(conn, Enum.map(players, &serialize_player/1))
  end

  def show(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    json(conn, serialize_player(player))
  end

  def create(conn, params) do
    case Players.create_player(params) do
      {:ok, player} ->
        conn
        |> put_status(:created)
        |> json(serialize_player(player))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    player = Players.get_player!(id)
    case Players.update_player(player, params) do
      {:ok, player} ->
        json(conn, serialize_player(player))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    Players.delete_player(player)
    send_resp(conn, :no_content, "")
  end

  # POST /api/players/{id}/promote
  def promote(conn, %{"id" => id}) do
    result = Players.player_promote_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/players/{id}/demote
  def demote(conn, %{"id" => id}) do
    result = Players.player_demote_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/players/{id}/win
  def record_win(conn, %{"id" => id}) do
    Players.player_record_win_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/players/{id}/loss
  def record_loss(conn, %{"id" => id}) do
    Players.player_record_loss_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # GET /api/players/{id}/win-rate
  def win_rate(conn, %{"id" => id}) do
    result = Players.player_win_rate_behavior(id)
    json(conn, %{result: result})
  end

  # POST /api/players/{id}/verify
  def verify(conn, %{"id" => id}) do
    Players.player_verify_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # PATCH /api/players/{id}/rating
  def update_rating(conn, %{"id" => id} = params) do
    delta = Map.get(params, "delta")
    Players.player_update_rating_behavior(id, delta)
    send_resp(conn, :no_content, "")
  end

  defp serialize_player(%Player{} = record) do
    Map.take(record, [:id, :display_name, :rank, :rating, :peak_rating, :bio, :country_code, :avatar_url, :preferred_format, :is_verified, :created_at, :last_active_at, :user_id, :season_stats_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
