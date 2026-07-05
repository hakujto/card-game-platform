class CreateTradeTransactionsAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :trade_transactions_audit_logs do |t|
      t.integer :record_id, null: false
      t.string  :field, limit: 100, null: false
      t.text    :old_value
      t.text    :new_value
      t.timestamp :changed_at, default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
