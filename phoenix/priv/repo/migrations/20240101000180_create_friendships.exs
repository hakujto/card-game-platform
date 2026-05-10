defmodule CardsProject.Repo.Migrations.CreateFriendships do
  use Ecto.Migration

  def change do
    create table(:friendships) do
      add :status, :string, default: "Pending"
      add :created_at, :naive_datetime
      add :requester_id, references(:players, on_delete: :nilify_all)
      add :receiver_id, references(:players, on_delete: :nilify_all)

      timestamps()
    end
    create index(:friendships, [:requester_id])
    create index(:friendships, [:receiver_id])
  end
end
