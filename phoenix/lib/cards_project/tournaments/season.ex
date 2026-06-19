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
    has_many :player_stats, CardsProject.Players.PlayerSeasonStats, foreign_key: :season_id
    has_many :tournaments, CardsProject.Tournaments.Tournament, foreign_key: :season_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :start_date, :end_date, :is_active, :format, :reward_description])
    |> validate_required([:name, :start_date, :end_date, :is_active])
    |> validate_inclusion(:format, ["Standard", "Extended", "Legacy", "Vintage", "Commander", "Draft"])
    |> then(fn cs ->
      lv = get_field(cs, :start_date)
      fv = get_field(cs, :end_date)
      if not is_nil(lv) and not is_nil(fv) and not (fv > lv) do
        Ecto.Changeset.add_error(cs, :end_date, "Season end date must be after start date")
      else
        cs
      end
    end)
  end

  # ── Business operations ────────────────────────────────────────────

  def activate(_record) do
    # TODO: implement Season.activate
    :ok
  end

  def deactivate(_record) do
    # TODO: implement Season.deactivate
    :ok
  end

  def finalize_rewards(_record) do
    # TODO: implement Season.finalize_rewards
    :ok
  end

  def is_ongoing(_record) do
    # TODO: implement Season.is_ongoing
    {:error, :not_implemented}
  end
end
