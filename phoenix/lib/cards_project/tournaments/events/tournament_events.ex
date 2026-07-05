defmodule CardsProject.Tournaments.Events.TournamentEvents do

  defmodule TournamentCompleted do
    @type t_tournament_id :: integer()
    @type t_season_id :: integer()
    @type t_completed_at :: NaiveDateTime.t()

    defstruct [:tournament_id, :season_id, :completed_at]
  end

  defmodule PlayerRegistered do
    @type t_tournament_id :: integer()
    @type t_player_id :: integer()
    @type t_registered_at :: NaiveDateTime.t()

    defstruct [:tournament_id, :player_id, :registered_at]
  end

end
