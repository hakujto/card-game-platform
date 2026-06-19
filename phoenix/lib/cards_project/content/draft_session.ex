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
    has_many :participants, CardsProject.Content.DraftParticipant, foreign_key: :session_id

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:seats, :time_per_pick_seconds, :created_at, :status, :draft_type, :completed_at, :card_set_id])
    |> validate_required([:seats, :time_per_pick_seconds, :created_at])
    |> validate_inclusion(:status, ["WaitingForPlayers", "Drafting", "Completed", "Abandoned"])
    |> validate_inclusion(:draft_type, ["Booster", "Cube", "Rochester"])
    |> validate_number(:seats, greater_than_or_equal_to: 2, less_than_or_equal_to: 16, message: "Draft session must have between 2 and 16 seats")
    |> validate_number(:time_per_pick_seconds, greater_than: 0, message: "Time per pick must be greater than zero")
    |> then(fn cs ->
      if not is_nil(get_field(cs, :completed_at)) and (get_field(cs, :status) != "Completed") do
        Ecto.Changeset.add_error(cs, :status, "completed_at can only be set when draft status is Completed")
      else
        cs
      end
    end)
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
