defmodule CardsProject.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :hashed_password, :string
    field :is_active, :boolean, default: true

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :hashed_password, :is_active])
    |> validate_required([:username, :email])
    |> unique_constraint(:email)
  end
end
