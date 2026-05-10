defmodule CardsProject.Tournaments.Season do
  use Ecto.Schema
  import Ecto.Changeset

  schema "seasons" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :format, :string
    field :is_active, :boolean, default: false
    field :reward_description, :string

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :start_date, :end_date, :is_active, :format, :reward_description])
    |> validate_required([:name, :start_date, :end_date, :is_active])
    |> validate_inclusion(:format, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
  end
end
