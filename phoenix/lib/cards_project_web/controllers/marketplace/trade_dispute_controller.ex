defmodule CardsProjectWeb.Marketplace.TradeDisputeController do
  use Phoenix.Controller, formats: [:json]
  import Plug.Conn

  alias CardsProject.Marketplace
  alias CardsProject.Marketplace.TradeDispute

  def index(conn, _params) do
    trade_disputes = Marketplace.list_trade_disputes()
    json(conn, Enum.map(trade_disputes, &serialize_trade_dispute/1))
  end

  def show(conn, %{"id" => id}) do
    trade_dispute = Marketplace.get_trade_dispute!(id)
    json(conn, serialize_trade_dispute(trade_dispute))
  end

  def create(conn, params) do
    case Marketplace.create_trade_dispute(params) do
      {:ok, trade_dispute} ->
        conn
        |> put_status(:created)
        |> json(serialize_trade_dispute(trade_dispute))

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: format_errors(changeset)})
    end
  end

  # POST /api/disputes/{id}/escalate
  def escalate(conn, %{"id" => id}) do
    Marketplace.trade_dispute_escalate_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/disputes/{id}/resolve
  def resolve(conn, %{"id" => id} = params) do
    resolution_text = Map.get(params, "resolution_text")
    Marketplace.trade_dispute_resolve_behavior(id, resolution_text)
    send_resp(conn, :no_content, "")
  end

  # POST /api/disputes/{id}/close
  def close_resolved(conn, %{"id" => id}) do
    Marketplace.trade_dispute_close_resolved_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # POST /api/disputes/{id}/review
  def review(conn, %{"id" => id}) do
    Marketplace.trade_dispute_review_behavior(id)
    send_resp(conn, :no_content, "")
  end

  # PATCH /api/trade_disputes/:id/transitions/open-to-underreview
  def transition_open_to_under_review(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Admin", "Moderator"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition Open -> UnderReview"}) |> halt()
    else
    trade_dispute = Marketplace.get_trade_dispute!(id)
    case Marketplace.transition_open_to_under_review_trade_dispute(trade_dispute) do
      {:ok, updated} ->
        json(conn, serialize_trade_dispute(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/trade_disputes/:id/transitions/underreview-to-resolved
  def transition_under_review_to_resolved(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Admin", "Moderator"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition UnderReview -> Resolved"}) |> halt()
    else
    trade_dispute = Marketplace.get_trade_dispute!(id)
    case Marketplace.transition_under_review_to_resolved_trade_dispute(trade_dispute) do
      {:ok, updated} ->
        json(conn, serialize_trade_dispute(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/trade_disputes/:id/transitions/underreview-to-escalated
  def transition_under_review_to_escalated(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Admin"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition UnderReview -> Escalated"}) |> halt()
    else
    trade_dispute = Marketplace.get_trade_dispute!(id)
    case Marketplace.transition_under_review_to_escalated_trade_dispute(trade_dispute) do
      {:ok, updated} ->
        json(conn, serialize_trade_dispute(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/trade_disputes/:id/transitions/escalated-to-resolved
  def transition_escalated_to_resolved(conn, %{"id" => id}) do
    user_role = conn.assigns[:current_user] && conn.assigns[:current_user].role
    unless user_role in ["Admin"] do
      conn |> put_status(:forbidden) |> json(%{error: "Insufficient role for transition Escalated -> Resolved"}) |> halt()
    else
    trade_dispute = Marketplace.get_trade_dispute!(id)
    case Marketplace.transition_escalated_to_resolved_trade_dispute(trade_dispute) do
      {:ok, updated} ->
        json(conn, serialize_trade_dispute(updated))

      {:error, :conflict, msg} ->
        conn |> put_status(:conflict) |> json(%{error: msg})

      {:error, :unprocessable, msg} ->
        conn |> put_status(:unprocessable_entity) |> json(%{error: msg})

      {:error, changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: format_errors(changeset)})
    end
    end
  end

  # PATCH /api/trade_disputes/:id/transitions/resolved-to-open
  def transition_resolved_to_open(conn, %{"id" => _id}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Transition Resolved -> Open is not allowed"})
  end

  defp serialize_trade_dispute(%TradeDispute{} = record) do
    record
    |> Map.take([:id, :status, :reason, :description, :resolution, :opened_at, :resolved_at, :transaction_id, :opened_by_id, :resolved_by_id])
    |> (fn m -> Map.put(Map.delete(m, :opened_at), :opened_at, Map.get(m, :opened_at)) end).()
    |> (fn m -> Map.put(Map.delete(m, :resolved_at), :resolved_at, Map.get(m, :resolved_at)) end).()
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
