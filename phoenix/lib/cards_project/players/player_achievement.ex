defmodule CardsProject.Players.PlayerAchievement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "player_achievements" do
    field :earned_at, :naive_datetime
    field :progress, :integer, default: 0
    field :is_completed, :boolean, default: false
    belongs_to :player, CardsProject.Players.Player
    belongs_to :achievement, CardsProject.Players.Achievement

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:earned_at, :progress, :is_completed, :player_id, :achievement_id])
    |> validate_required([:earned_at, :progress, :is_completed])
  end
end
