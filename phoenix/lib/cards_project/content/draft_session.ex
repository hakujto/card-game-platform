defmodule CardsProject.Content.DraftSession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "draft_sessions" do
    field :status, :string
    field :draft_type, :string
    field :seats, :integer, default: 8
    field :time_per_pick_seconds, :integer, default: 30
    field :created_at, :naive_datetime
    field :completed_at, :naive_datetime
    belongs_to :card_set, CardsProject.Cards.CardSet
    belongs_to :participants, CardsProject.Content.DraftParticipant

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:seats, :time_per_pick_seconds, :created_at, :status, :draft_type, :completed_at, :card_set_id])
    |> validate_required([:seats, :time_per_pick_seconds, :created_at])
    |> validate_inclusion(:status, ["WaitingForPlayers", "Drafting", "Completed", "Abandoned"])
    |> validate_inclusion(:draft_type, ["Booster", "Cube", "Rochester"])
  end

  # ── Business operations ────────────────────────────────────────────

  def start(_record) do
    # TODO: implement DraftSession.start
    :ok
  end

  def abandon(_record) do
    # TODO: implement DraftSession.abandon
    :ok
  end

  def complete(_record) do
    # TODO: implement DraftSession.complete
    :ok
  end

  def is_full(_record) do
    # TODO: implement DraftSession.is_full
    {:error, :not_implemented}
  end

  # ── Lifecycle state machine ─────────────────────────────────────────
  @allowed_transitions %{
    "WaitingForPlayers" => ["Drafting", "Abandoned"],
    "Drafting" => ["Completed", "Abandoned"]
  }

  def assert_transition(%__MODULE__{status: current}, to) do
    allowed = Map.get(@allowed_transitions, current, [])
    if to in allowed do
      :ok
    else
      {:error, "Transition #{current} -> #{to} not allowed"}
    end
  end
end
