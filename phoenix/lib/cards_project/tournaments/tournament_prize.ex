defmodule CardsProject.Tournaments.TournamentPrize do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tournament_prizes" do
    field :placement_from, :integer
    field :placement_to, :integer
    field :prize_type, :string
    field :amount, :decimal
    field :description, :string
    field :packs_count, :integer
    field :season_points, :integer, default: 0
    belongs_to :tournament, CardsProject.Tournaments.Tournament

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:placement_from, :placement_to, :amount, :season_points, :prize_type, :description, :packs_count, :tournament_id])
    |> validate_required([:placement_from, :placement_to, :amount, :season_points])
    |> validate_inclusion(:prize_type, ["Currency", "Cards", "BoosterPacks", "Trophy", "SeasonPoints", "Mixed"])
    |> then(fn cs ->
      lv = get_field(cs, :placement_from)
      fv = get_field(cs, :placement_to)
      if not is_nil(lv) and not is_nil(fv) and not (fv >= lv) do
        Ecto.Changeset.add_error(cs, :placement_to, "placement_to must be greater than or equal to placement_from")
      else
        cs
      end
    end)
    |> validate_number(:placement_from, greater_than: 0, message: "placement_from must be greater than zero")
    |> validate_number(:amount, greater_than_or_equal_to: 0, message: "Prize amount must not be negative")
  end

  # ── Business operations ────────────────────────────────────────────

  def applies_to_placement(_record, _placement) do
    # TODO: implement TournamentPrize.applies_to_placement
    {:error, :not_implemented}
  end

  def award_to_player(_record, _player_id) do
    # TODO: implement TournamentPrize.award_to_player
    :ok
  end
end
