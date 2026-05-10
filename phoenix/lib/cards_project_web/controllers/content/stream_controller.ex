defmodule CardsProjectWeb.Content.StreamController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Content
  alias CardsProject.Content.Stream

  def index(conn, _params) do
    streams = Content.list_streams()
    json(conn, Enum.map(streams, &serialize_stream/1))
  end

  def show(conn, %{"id" => id}) do
    stream = Content.get_stream!(id)
    json(conn, serialize_stream(stream))
  end

  def create(conn, params) do
    case Content.create_stream(params) do
      {:ok, stream} ->
        conn
        |> put_status(:created)
        |> json(serialize_stream(stream))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    stream = Content.get_stream!(id)
    case Content.update_stream(stream, params) do
      {:ok, stream} ->
        json(conn, serialize_stream(stream))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  def delete(conn, %{"id" => id}) do
    stream = Content.get_stream!(id)
    Content.delete_stream(stream)
    send_resp(conn, :no_content, "")
  end

  defp serialize_stream(%Stream{} = record) do
    Map.take(record, [:id, :title, :stream_url, :platform, :status, :viewer_count_peak, :scheduled_start, :actual_start, :ended_at, :vod_url, :tournament_id, :streamer_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
