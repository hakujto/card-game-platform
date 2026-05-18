defmodule CardsProject.Tournaments do
  @moduledoc """
  The Tournaments BC context.
  """

  import Ecto.Query, warn: false
  alias CardsProject.Repo

  alias CardsProject.Tournaments.Season
  alias CardsProject.Tournaments.Tournament
  alias CardsProject.Tournaments.TournamentJudge
  alias CardsProject.Tournaments.TournamentRegistration
  alias CardsProject.Tournaments.TournamentRound
  alias CardsProject.Tournaments.Match
  alias CardsProject.Tournaments.Game
  alias CardsProject.Tournaments.TournamentPrize
  alias CardsProject.Tournaments.AwardedPrize

  # ── Season ─────────────────────────────────────────────────────

  def list_seasons, do: Repo.all(Season)

  def get_season!(id), do: Repo.get!(Season, id)

  def create_season(attrs \\ %{}) do
    %Season{}
    |> Season.changeset(attrs)
    |> Repo.insert()
  end

  def update_season(%Season{} = season, attrs) do
    season
    |> Season.changeset(attrs)
    |> Repo.update()
  end

  def delete_season(%Season{} = season), do: Repo.delete(season)

  def change_season(%Season{} = season, attrs \\ %{}) do
    Season.changeset(season, attrs)
  end

  def season_activate_behavior(id) do
    season = Repo.get!(Season, id)
    Season.activate(season)
    Repo.update!(Season.changeset(season, %{}))
  end

  def season_deactivate_behavior(id) do
    season = Repo.get!(Season, id)
    Season.deactivate(season)
    Repo.update!(Season.changeset(season, %{}))
  end

  def season_finalize_rewards_behavior(id) do
    season = Repo.get!(Season, id)
    Season.finalize_rewards(season)
    Repo.update!(Season.changeset(season, %{}))
  end

  def season_is_ongoing_behavior(id) do
    season = Repo.get!(Season, id)
    result = Season.is_ongoing(season)
    Repo.update!(Season.changeset(season, %{}))
    result
  end

  # ── Tournament ─────────────────────────────────────────────────────

  def list_tournaments, do: Repo.all(Tournament)

  def get_tournament!(id), do: Repo.get!(Tournament, id)

  def create_tournament(attrs \\ %{}) do
    %Tournament{}
    |> Tournament.changeset(attrs)
    |> Repo.insert()
  end

  def update_tournament(%Tournament{} = tournament, attrs) do
    tournament
    |> Tournament.changeset(attrs)
    |> Repo.update()
  end

  def delete_tournament(%Tournament{} = tournament), do: Repo.delete(tournament)

  def change_tournament(%Tournament{} = tournament, attrs \\ %{}) do
    Tournament.changeset(tournament, attrs)
  end

  def tournament_start_behavior(id) do
    tournament = Repo.get!(Tournament, id)
    Tournament.start(tournament)
    Repo.update!(Tournament.changeset(tournament, %{}))
  end

  def tournament_cancel_behavior(id) do
    tournament = Repo.get!(Tournament, id)
    Tournament.cancel(tournament)
    Repo.update!(Tournament.changeset(tournament, %{}))
  end

  def tournament_complete_behavior(id) do
    tournament = Repo.get!(Tournament, id)
    Tournament.complete(tournament)
    Repo.update!(Tournament.changeset(tournament, %{}))
  end

  def tournament_generate_round_behavior(id) do
    tournament = Repo.get!(Tournament, id)
    Tournament.generate_round(tournament)
    Repo.update!(Tournament.changeset(tournament, %{}))
  end

  def tournament_calculate_prize_distribution_behavior(id) do
    tournament = Repo.get!(Tournament, id)
    result = Tournament.calculate_prize_distribution(tournament)
    Repo.update!(Tournament.changeset(tournament, %{}))
    result
  end

  def tournament_register_player_behavior(id, player_id, deck_id) do
    tournament = Repo.get!(Tournament, id)
    Tournament.register_player(tournament, player_id, deck_id)
    Repo.update!(Tournament.changeset(tournament, %{}))
  end

  def tournament_is_full_behavior(id) do
    tournament = Repo.get!(Tournament, id)
    result = Tournament.is_full(tournament)
    Repo.update!(Tournament.changeset(tournament, %{}))
    result
  end

  # ── TournamentJudge ─────────────────────────────────────────────────────

  def list_tournament_judges, do: Repo.all(TournamentJudge)

  def get_tournament_judge!(id), do: Repo.get!(TournamentJudge, id)

  def create_tournament_judge(attrs \\ %{}) do
    %TournamentJudge{}
    |> TournamentJudge.changeset(attrs)
    |> Repo.insert()
  end

  def update_tournament_judge(%TournamentJudge{} = tournament_judge, attrs) do
    tournament_judge
    |> TournamentJudge.changeset(attrs)
    |> Repo.update()
  end

  def delete_tournament_judge(%TournamentJudge{} = tournament_judge), do: Repo.delete(tournament_judge)

  def change_tournament_judge(%TournamentJudge{} = tournament_judge, attrs \\ %{}) do
    TournamentJudge.changeset(tournament_judge, attrs)
  end

  def tournament_judge_promote_to_head_behavior(id) do
    tournament_judge = Repo.get!(TournamentJudge, id)
    TournamentJudge.promote_to_head(tournament_judge)
    Repo.update!(TournamentJudge.changeset(tournament_judge, %{}))
  end

  def tournament_judge_remove_behavior(id) do
    tournament_judge = Repo.get!(TournamentJudge, id)
    TournamentJudge.remove(tournament_judge)
    Repo.update!(TournamentJudge.changeset(tournament_judge, %{}))
  end

  # ── TournamentRegistration ─────────────────────────────────────────────────────

  def list_tournament_registrations, do: Repo.all(TournamentRegistration)

  def get_tournament_registration!(id), do: Repo.get!(TournamentRegistration, id)

  def create_tournament_registration(attrs \\ %{}) do
    %TournamentRegistration{}
    |> TournamentRegistration.changeset(attrs)
    |> Repo.insert()
  end

  def update_tournament_registration(%TournamentRegistration{} = tournament_registration, attrs) do
    tournament_registration
    |> TournamentRegistration.changeset(attrs)
    |> Repo.update()
  end

  def delete_tournament_registration(%TournamentRegistration{} = tournament_registration), do: Repo.delete(tournament_registration)

  def change_tournament_registration(%TournamentRegistration{} = tournament_registration, attrs \\ %{}) do
    TournamentRegistration.changeset(tournament_registration, attrs)
  end

  def tournament_registration_withdraw_behavior(id) do
    tournament_registration = Repo.get!(TournamentRegistration, id)
    TournamentRegistration.withdraw(tournament_registration)
    Repo.update!(TournamentRegistration.changeset(tournament_registration, %{}))
  end

  def tournament_registration_disqualify_behavior(id, reason) do
    tournament_registration = Repo.get!(TournamentRegistration, id)
    TournamentRegistration.disqualify(tournament_registration, reason)
    Repo.update!(TournamentRegistration.changeset(tournament_registration, %{}))
  end

  def tournament_registration_promote_from_waitlist_behavior(id) do
    tournament_registration = Repo.get!(TournamentRegistration, id)
    TournamentRegistration.promote_from_waitlist(tournament_registration)
    Repo.update!(TournamentRegistration.changeset(tournament_registration, %{}))
  end

  # ── TournamentRound ─────────────────────────────────────────────────────

  def list_tournament_rounds, do: Repo.all(TournamentRound)

  def get_tournament_round!(id), do: Repo.get!(TournamentRound, id)

  def create_tournament_round(attrs \\ %{}) do
    %TournamentRound{}
    |> TournamentRound.changeset(attrs)
    |> Repo.insert()
  end

  def update_tournament_round(%TournamentRound{} = tournament_round, attrs) do
    tournament_round
    |> TournamentRound.changeset(attrs)
    |> Repo.update()
  end

  def delete_tournament_round(%TournamentRound{} = tournament_round), do: Repo.delete(tournament_round)

  def change_tournament_round(%TournamentRound{} = tournament_round, attrs \\ %{}) do
    TournamentRound.changeset(tournament_round, attrs)
  end

  def tournament_round_start_behavior(id) do
    tournament_round = Repo.get!(TournamentRound, id)
    TournamentRound.start(tournament_round)
    Repo.update!(TournamentRound.changeset(tournament_round, %{}))
  end

  def tournament_round_complete_behavior(id) do
    tournament_round = Repo.get!(TournamentRound, id)
    TournamentRound.complete(tournament_round)
    Repo.update!(TournamentRound.changeset(tournament_round, %{}))
  end

  def tournament_round_generate_pairings_behavior(id) do
    tournament_round = Repo.get!(TournamentRound, id)
    TournamentRound.generate_pairings(tournament_round)
    Repo.update!(TournamentRound.changeset(tournament_round, %{}))
  end

  def tournament_round_is_time_expired_behavior(id) do
    tournament_round = Repo.get!(TournamentRound, id)
    result = TournamentRound.is_time_expired(tournament_round)
    Repo.update!(TournamentRound.changeset(tournament_round, %{}))
    result
  end

  # ── Match ─────────────────────────────────────────────────────

  def list_matches, do: Repo.all(Match)

  def get_match!(id), do: Repo.get!(Match, id)

  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  def delete_match(%Match{} = match), do: Repo.delete(match)

  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  def match_record_result_behavior(id, p1_wins, p2_wins) do
    match = Repo.get!(Match, id)
    Match.record_result(match, p1_wins, p2_wins)
    Match.determine_winner(match)  # @after
    Repo.update!(Match.changeset(match, %{}))
  end

  def match_determine_winner_behavior(id) do
    match = Repo.get!(Match, id)
    result = Match.determine_winner(match)
    Repo.update!(Match.changeset(match, %{}))
    result
  end

  def match_concede_behavior(id, player_id) do
    match = Repo.get!(Match, id)
    Match.concede(match, player_id)
    Repo.update!(Match.changeset(match, %{}))
  end

  def match_draw_behavior(id) do
    match = Repo.get!(Match, id)
    Match.draw(match)
    Repo.update!(Match.changeset(match, %{}))
  end

  # ── Game ─────────────────────────────────────────────────────

  def list_games, do: Repo.all(Game)

  def get_game!(id), do: Repo.get!(Game, id)

  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  def delete_game(%Game{} = game), do: Repo.delete(game)

  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  def game_record_winner_behavior(id, winner_side) do
    game = Repo.get!(Game, id)
    Game.record_winner(game, winner_side)
    Repo.update!(Game.changeset(game, %{}))
  end

  def game_duration_minutes_behavior(id) do
    game = Repo.get!(Game, id)
    result = Game.duration_minutes(game)
    Repo.update!(Game.changeset(game, %{}))
    result
  end

  # ── TournamentPrize ─────────────────────────────────────────────────────

  def list_tournament_prizes, do: Repo.all(TournamentPrize)

  def get_tournament_prize!(id), do: Repo.get!(TournamentPrize, id)

  def create_tournament_prize(attrs \\ %{}) do
    %TournamentPrize{}
    |> TournamentPrize.changeset(attrs)
    |> Repo.insert()
  end

  def update_tournament_prize(%TournamentPrize{} = tournament_prize, attrs) do
    tournament_prize
    |> TournamentPrize.changeset(attrs)
    |> Repo.update()
  end

  def delete_tournament_prize(%TournamentPrize{} = tournament_prize), do: Repo.delete(tournament_prize)

  def change_tournament_prize(%TournamentPrize{} = tournament_prize, attrs \\ %{}) do
    TournamentPrize.changeset(tournament_prize, attrs)
  end

  def tournament_prize_applies_to_placement_behavior(id, placement) do
    tournament_prize = Repo.get!(TournamentPrize, id)
    result = TournamentPrize.applies_to_placement(tournament_prize, placement)
    Repo.update!(TournamentPrize.changeset(tournament_prize, %{}))
    result
  end

  def tournament_prize_award_to_player_behavior(id, player_id) do
    tournament_prize = Repo.get!(TournamentPrize, id)
    TournamentPrize.award_to_player(tournament_prize, player_id)
    Repo.update!(TournamentPrize.changeset(tournament_prize, %{}))
  end

  # ── AwardedPrize ─────────────────────────────────────────────────────

  def list_awarded_prizes, do: Repo.all(AwardedPrize)

  def get_awarded_prize!(id), do: Repo.get!(AwardedPrize, id)

  def create_awarded_prize(attrs \\ %{}) do
    %AwardedPrize{}
    |> AwardedPrize.changeset(attrs)
    |> Repo.insert()
  end

  def update_awarded_prize(%AwardedPrize{} = awarded_prize, attrs) do
    awarded_prize
    |> AwardedPrize.changeset(attrs)
    |> Repo.update()
  end

  def delete_awarded_prize(%AwardedPrize{} = awarded_prize), do: Repo.delete(awarded_prize)

  def change_awarded_prize(%AwardedPrize{} = awarded_prize, attrs \\ %{}) do
    AwardedPrize.changeset(awarded_prize, attrs)
  end

  def awarded_prize_claim_behavior(id) do
    awarded_prize = Repo.get!(AwardedPrize, id)
    AwardedPrize.claim(awarded_prize)
    Repo.update!(AwardedPrize.changeset(awarded_prize, %{}))
  end

end
