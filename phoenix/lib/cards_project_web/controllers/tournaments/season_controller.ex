defmodule CardsProjectWeb.Tournaments.SeasonController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Tournaments
  alias CardsProject.Tournaments.Season

  def index(conn, _params) do
    seasons = Tournaments.list_seasons()
    json(conn, Enum.map(seasons, &serialize_season/1))
  end

  def show(conn, %{"id" => id}) do
    season = Tournaments.get_season!(id)
    json(conn, serialize_season(season))
  end

  def create(conn, params) do
    case Tournaments.create_season(params) do
      {:ok, season} ->
        conn
        |> put_status(:created)
        |> json(serialize_season(season))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    season = Tournaments.get_season!(id)
    case Tournaments.update_season(season, params) do
      {:ok, season} ->
        json(conn, serialize_season(season))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    season = Tournaments.get_season!(id)
    Tournaments.delete_season(season)
    send_resp(conn, :no_content, "")
  end

  defp serialize_season(%Season{} = record) do
    Map.take(record, [:id, :name, :start_date, :end_date, :format, :is_active, :reward_description])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
