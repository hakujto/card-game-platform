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
    |> validate_number(:progress, greater_than_or_equal_to: 0, message: "Achievement progress must not be negative")
    |> then(fn cs ->
      if get_field(cs, :is_completed) == "true" and (not ((get_field(cs, :progress) || 0) > 0)) do
        Ecto.Changeset.add_error(cs, :progress, "Completed achievement must have progress greater than zero")
      else
        cs
      end
    end)
  end

  # ── Business operations ────────────────────────────────────────────

  def increment_progress(_record, _amount) do
    # TODO: implement PlayerAchievement.increment_progress
    :ok
  end

  def complete(_record) do
    # TODO: implement PlayerAchievement.complete
    :ok
  end
end
