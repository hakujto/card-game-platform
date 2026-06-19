defmodule CardsProject.Players.Achievement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "achievements" do
    field :name, :string
    field :description, :string
    field :icon_url, :string
    field :points, :integer, default: 10
    field :rarity, :string
    field :is_hidden, :boolean, default: false
    many_to_many :players, CardsProject.Players.Player, join_through: "player_achievements"
    has_many :player_records, CardsProject.Players.PlayerAchievement, foreign_key: :achievement_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :description, :points, :is_hidden, :icon_url, :rarity])
    |> validate_required([:name, :description, :points, :is_hidden])
    |> validate_inclusion(:rarity, ["Common", "Uncommon", "Rare", "Epic", "Legendary"])
    |> validate_number(:points, greater_than: 0, message: "Achievement must award at least one point")
  end

  # ── Business operations ────────────────────────────────────────────

  def point_value(_record, _multiplier) do
    # TODO: implement Achievement.point_value
    {:error, :not_implemented}
  end

  def reveal(_record) do
    # TODO: implement Achievement.reveal
    :ok
  end
end
