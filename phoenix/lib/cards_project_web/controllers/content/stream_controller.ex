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

  # POST /api/streams/{id}/live
  def go_live(conn, %{"id" => id}) do
    Content.stream_go_live_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/streams/{id}/end
  def end_action(conn, %{"id" => id}) do
    Content.stream_end_action_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # PATCH /api/streams/{id}/viewers
  def update_viewer_peak(conn, %{"id" => id} = params) do
    count = Map.get(params, "count")
    Content.stream_update_viewer_peak_behavior(id, count)
    send_resp(conn, :no_content, "")
  end

  # GET /api/streams/{id}/duration
  def duration_minutes(conn, %{"id" => id}) do
    result = Content.stream_duration_minutes_behavior(id)
    json(conn, %{result: result})
  end

  # PATCH /api/streams/:id/transitions/scheduled-to-live
  def transition_scheduled_to_live(conn, %{"id" => id}) do
    stream = Content.get_stream!(id)
    case Content.transition_scheduled_to_live_stream(stream) do
      {:ok, updated} ->
        json(conn, serialize_stream(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/streams/:id/transitions/live-to-ended
  def transition_live_to_ended(conn, %{"id" => id}) do
    stream = Content.get_stream!(id)
    case Content.transition_live_to_ended_stream(stream) do
      {:ok, updated} ->
        json(conn, serialize_stream(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
  end

  # PATCH /api/streams/:id/transitions/ended-to-live
  def transition_ended_to_live(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Ended -> Live is not allowed"})
  end

  defp serialize_stream(%Stream{} = record) do
    Map.take(record, [:id, :title, :stream_url, :status, :platform, :language, :is_official, :viewer_count_peak, :scheduled_start, :actual_start, :ended_at, :vod_url, :tournament_id, :streamer_id])
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
