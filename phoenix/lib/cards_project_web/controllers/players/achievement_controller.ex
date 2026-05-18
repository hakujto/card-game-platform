defmodule CardsProjectWeb.Players.AchievementController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Players
  alias CardsProject.Players.Achievement

  def index(conn, _params) do
    achievements = Players.list_achievements()
    json(conn, Enum.map(achievements, &serialize_achievement/1))
  end

  def show(conn, %{"id" => id}) do
    achievement = Players.get_achievement!(id)
    json(conn, serialize_achievement(achievement))
  end

  def create(conn, params) do
    case Players.create_achievement(params) do
      {:ok, achievement} ->
        conn
        |> put_status(:created)
        |> json(serialize_achievement(achievement))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    achievement = Players.get_achievement!(id)
    case Players.update_achievement(achievement, params) do
      {:ok, achievement} ->
        json(conn, serialize_achievement(achievement))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    achievement = Players.get_achievement!(id)
    Players.delete_achievement(achievement)
    send_resp(conn, :no_content, "")
  end

  # GET /api/achievements/{id}/point-value
  def point_value(conn, %{"id" => id} = params) do
    multiplier = Map.get(params, "multiplier")
    result = Players.achievement_point_value_behavior(id, multiplier)
    json(conn, %{result: result})
  end

  # POST /api/achievements/{id}/reveal
  def reveal(conn, %{"id" => id}) do
    Players.achievement_reveal_behavior(id)
    send_resp(conn, :no_content, "")
  end

  defp serialize_achievement(%Achievement{} = record) do
    Map.take(record, [:id, :name, :description, :icon_url, :points, :rarity, :is_hidden])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
