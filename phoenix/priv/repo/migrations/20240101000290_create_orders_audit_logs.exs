defmodule CardsProject.Repo.Migrations.CreateOrdersAuditLogs do
  use Ecto.Migration
  def change do
    create table(:orders_audit_logs) do
      add :record_id, :integer, null: false
      add :field, :string, size: 100, null: false
      add :old_value, :text
      add :new_value, :text
      timestamps(updated_at: false)
    end
  end
end
