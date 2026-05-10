defmodule CardsProject.Repo.Migrations.CreateCoupons do
  use Ecto.Migration

  def change do
    create table(:coupons) do
      add :code, :string
      add :discount_type, :string, default: "Percent"
      add :discount_value, :decimal
      add :min_order_value, :decimal, default: 0
      add :max_uses, :integer, null: true
      add :uses_count, :integer, default: 0
      add :valid_from, :naive_datetime
      add :valid_until, :naive_datetime
      add :is_active, :boolean, default: true

      timestamps()
    end
  end
end
