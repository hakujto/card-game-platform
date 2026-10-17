require "kemal"
require "../models/tournaments"
require "../db"

module TournamentsRoutes
  def self.season_routes
    get "/api/seasons" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM seasons WHERE name LIKE ?", "%#{q}%", as: Season)
      else
        AppDB.query_all("SELECT * FROM seasons", as: Season)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/seasons/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM seasons WHERE id = ?", id, as: Season)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/seasons" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO seasons (name, start_date, end_date, format, is_active, reward_description) VALUES (?, ?, ?, ?, ?, ?)",
        data["name"]?.try(&.as_s) || "",
        data["start_date"]?.try(&.as_s) || "",
        data["end_date"]?.try(&.as_s) || "",
        data["format"]?.try(&.as_s) || "Standard",
        data["is_active"]?.try(&.as_bool?) || false,
        data["reward_description"]?.try(&.as_s?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM seasons WHERE id = ?", id, as: Season)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/seasons/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE seasons SET name = ?, start_date = ?, end_date = ?, format = ?, is_active = ?, reward_description = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["name"]?.try(&.as_s) || "",
        data["start_date"]?.try(&.as_s) || "",
        data["end_date"]?.try(&.as_s) || "",
        data["format"]?.try(&.as_s) || "Standard",
        data["is_active"]?.try(&.as_bool?) || false,
        data["reward_description"]?.try(&.as_s?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM seasons WHERE id = ?", id, as: Season)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/seasons/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("name")
        updates << "name = ?"
        values << data["name"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("start_date")
        updates << "start_date = ?"
        values << data["start_date"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("end_date")
        updates << "end_date = ?"
        values << data["end_date"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("format")
        updates << "format = ?"
        values << data["format"]?.try(&.as_s) || "Standard"
      end
      if data.as_h.has_key?("is_active")
        updates << "is_active = ?"
        values << data["is_active"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("reward_description")
        updates << "reward_description = ?"
        values << data["reward_description"]?.try(&.as_s?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE seasons SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM seasons WHERE id = ?", id, as: Season)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/seasons/{id}/activate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement activate behavior
      {result: "ok"}.to_json
    end

    post "/api/seasons/{id}/deactivate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement deactivate behavior
      {result: "ok"}.to_json
    end

    post "/api/seasons/{id}/finalize" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement finalize_rewards behavior
      {result: "ok"}.to_json
    end

    get "/api/seasons/{id}/ongoing" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_ongoing behavior
      {result: "ok"}.to_json
    end

  end
  def self.tournament_routes
    get "/api/tournaments" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM tournaments WHERE name LIKE ?", "%#{q}%", as: Tournament)
      else
        AppDB.query_all("SELECT * FROM tournaments", as: Tournament)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/tournaments/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM tournaments WHERE id = ?", id, as: Tournament)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/tournaments" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO tournaments (public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["public_id"]?.try(&.as_s) || "",
        data["name"]?.try(&.as_s) || "",
        data["description"]?.try(&.as_s?),
        data["status"]?.try(&.as_s) || "Draft",
        data["bracket_data"]?.try(&.to_json),
        data["format"]?.try(&.as_s) || "Standard",
        data["tournament_type"]?.try(&.as_s) || "Swiss",
        data["max_players"]?.try(&.as_i?) || 0,
        data["entry_fee"]?.try(&.as_f?) || 0.0,
        data["prize_pool"]?.try(&.as_f?) || 0.0,
        data["startTime"]?.try(&.as_s) || "",
        data["endTime"]?.try(&.as_s?),
        data["is_online"]?.try(&.as_bool?) || true,
        data["location"]?.try(&.as_s?),
        data["rules_text"]?.try(&.as_s?),
        data["season_id"]?.try(&.as_i64?),
        data["organizer_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM tournaments WHERE id = ?", id, as: Tournament)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/tournaments/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE tournaments SET public_id = ?, name = ?, description = ?, bracket_data = ?, format = ?, tournament_type = ?, max_players = ?, entry_fee = ?, prize_pool = ?, start_time = ?, end_time = ?, is_online = ?, location = ?, rules_text = ?, season_id = ?, organizer_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["public_id"]?.try(&.as_s) || "",
        data["name"]?.try(&.as_s) || "",
        data["description"]?.try(&.as_s?),
        data["bracket_data"]?.try(&.to_json),
        data["format"]?.try(&.as_s) || "Standard",
        data["tournament_type"]?.try(&.as_s) || "Swiss",
        data["max_players"]?.try(&.as_i?) || 0,
        data["entry_fee"]?.try(&.as_f?) || 0.0,
        data["prize_pool"]?.try(&.as_f?) || 0.0,
        data["startTime"]?.try(&.as_s) || "",
        data["endTime"]?.try(&.as_s?),
        data["is_online"]?.try(&.as_bool?) || true,
        data["location"]?.try(&.as_s?),
        data["rules_text"]?.try(&.as_s?),
        data["season_id"]?.try(&.as_i64?),
        data["organizer_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM tournaments WHERE id = ?", id, as: Tournament)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/tournaments/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("public_id")
        updates << "public_id = ?"
        values << data["public_id"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("name")
        updates << "name = ?"
        values << data["name"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("description")
        updates << "description = ?"
        values << data["description"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("bracket_data")
        updates << "bracket_data = ?"
        values << data["bracket_data"]?.try(&.to_json)
      end
      if data.as_h.has_key?("format")
        updates << "format = ?"
        values << data["format"]?.try(&.as_s) || "Standard"
      end
      if data.as_h.has_key?("tournament_type")
        updates << "tournament_type = ?"
        values << data["tournament_type"]?.try(&.as_s) || "Swiss"
      end
      if data.as_h.has_key?("max_players")
        updates << "max_players = ?"
        values << data["max_players"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("entry_fee")
        updates << "entry_fee = ?"
        values << data["entry_fee"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("prize_pool")
        updates << "prize_pool = ?"
        values << data["prize_pool"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("startTime")
        updates << "start_time = ?"
        values << data["startTime"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("endTime")
        updates << "end_time = ?"
        values << data["endTime"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("is_online")
        updates << "is_online = ?"
        values << data["is_online"]?.try(&.as_bool?) || true
      end
      if data.as_h.has_key?("location")
        updates << "location = ?"
        values << data["location"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("rules_text")
        updates << "rules_text = ?"
        values << data["rules_text"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("season_id")
        updates << "season_id = ?"
        values << data["season_id"]?.try(&.as_i64?)
      end
      if data.as_h.has_key?("organizer_id")
        updates << "organizer_id = ?"
        values << data["organizer_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE tournaments SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM tournaments WHERE id = ?", id, as: Tournament)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/tournaments/{id}/start" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement start behavior
      {result: "ok"}.to_json
    end

    post "/api/tournaments/{id}/cancel" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement cancel behavior
      {result: "ok"}.to_json
    end

    post "/api/tournaments/{id}/complete" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement complete behavior
      {result: "ok"}.to_json
    end

    post "/api/tournaments/{id}/rounds" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement generate_round behavior
      {result: "ok"}.to_json
    end

    get "/api/tournaments/{id}/prizes" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement calculate_prize_distribution behavior
      {result: "ok"}.to_json
    end

    post "/api/tournaments/{id}/register" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement register_player behavior
      {result: "ok"}.to_json
    end

    get "/api/tournaments/{id}/full" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_full behavior
      {result: "ok"}.to_json
    end

  end
  def self.tournament_judge_routes
    get "/api/tournament_judges" do |env|
      rows = AppDB.query_all("SELECT * FROM tournament_judges", as: TournamentJudge)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/tournament_judges/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM tournament_judges WHERE id = ?", id, as: TournamentJudge)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/tournament_judges" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO tournament_judges (role, tournament_id, player_id) VALUES (?, ?, ?)",
        data["role"]?.try(&.as_s) || "Judge",
        data["tournament_id"]?.try(&.as_i64?),
        data["player_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM tournament_judges WHERE id = ?", id, as: TournamentJudge)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/tournament_judges/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM tournament_judges WHERE id = ?", id)
      env.response.status_code = 204
    end

    post "/api/tournament-judges/{id}/promote" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement promote_to_head behavior
      {result: "ok"}.to_json
    end

    delete "/api/tournament-judges/{id}" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement remove behavior
      {result: "ok"}.to_json
    end

  end
  def self.tournament_registration_routes
    get "/api/tournament_registrations" do |env|
      rows = AppDB.query_all("SELECT * FROM tournament_registrations", as: TournamentRegistration)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/tournament_registrations/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM tournament_registrations WHERE id = ?", id, as: TournamentRegistration)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/tournament_registrations" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO tournament_registrations (status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        data["status"]?.try(&.as_s) || "Registered",
        data["seed"]?.try(&.as_s?),
        data["final_standing"]?.try(&.as_s?),
        data["points_earned"]?.try(&.as_i?) || 0,
        data["registeredAt"]?.try(&.as_s) || "",
        data["tournament_id"]?.try(&.as_i64?),
        data["player_id"]?.try(&.as_i64?),
        data["deck_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM tournament_registrations WHERE id = ?", id, as: TournamentRegistration)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    post "/api/registrations/{id}/withdraw" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement withdraw behavior
      {result: "ok"}.to_json
    end

    post "/api/registrations/{id}/disqualify" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement disqualify behavior
      {result: "ok"}.to_json
    end

    post "/api/registrations/{id}/promote" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement promote_from_waitlist behavior
      {result: "ok"}.to_json
    end

  end
  def self.tournament_round_routes
    get "/api/tournament_rounds" do |env|
      rows = AppDB.query_all("SELECT * FROM tournament_rounds", as: TournamentRound)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/tournament_rounds/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM tournament_rounds WHERE id = ?", id, as: TournamentRound)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/tournament_rounds" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO tournament_rounds (round_number, status, started_at, ended_at, time_limit_minutes, tournament_id) VALUES (?, ?, ?, ?, ?, ?)",
        data["round_number"]?.try(&.as_i?) || 0,
        data["status"]?.try(&.as_s) || "Pending",
        data["startedAt"]?.try(&.as_s?),
        data["endedAt"]?.try(&.as_s?),
        data["time_limit_minutes"]?.try(&.as_i?) || 50,
        data["tournament_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM tournament_rounds WHERE id = ?", id, as: TournamentRound)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    post "/api/rounds/{id}/start" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement start behavior
      {result: "ok"}.to_json
    end

    post "/api/rounds/{id}/complete" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement complete behavior
      {result: "ok"}.to_json
    end

    post "/api/rounds/{id}/pairings" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement generate_pairings behavior
      {result: "ok"}.to_json
    end

    get "/api/rounds/{id}/time-expired" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_time_expired behavior
      {result: "ok"}.to_json
    end

  end
  def self.match_routes
    get "/api/matches" do |env|
      rows = AppDB.query_all("SELECT * FROM matches", as: Match)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/matches/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM matches WHERE id = ?", id, as: Match)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/matches" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO matches (table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["table_number"]?.try(&.as_s?),
        data["status"]?.try(&.as_s) || "Pending",
        data["player1_wins"]?.try(&.as_i?) || 0,
        data["player2_wins"]?.try(&.as_i?) || 0,
        data["startedAt"]?.try(&.as_s?),
        data["endedAt"]?.try(&.as_s?),
        data["result_notes"]?.try(&.as_s?),
        data["round_id"]?.try(&.as_i64?),
        data["player1_id"]?.try(&.as_i64?),
        data["player2_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM matches WHERE id = ?", id, as: Match)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    post "/api/matches/{id}/record" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement record_result behavior
      {result: "ok"}.to_json
    end

    post "/api/matches/{id}/finalize" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement finalize_result behavior
      {result: "ok"}.to_json
    end

    get "/api/matches/{id}/winner" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement determine_winner behavior
      {result: "ok"}.to_json
    end

    post "/api/matches/{id}/concede" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement concede behavior
      {result: "ok"}.to_json
    end

    post "/api/matches/{id}/draw" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement draw behavior
      {result: "ok"}.to_json
    end

  end
  def self.game_routes
    get "/api/games" do |env|
      rows = AppDB.query_all("SELECT * FROM games", as: Game)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/games/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM games WHERE id = ?", id, as: Game)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/games" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO games (game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["game_number"]?.try(&.as_i?) || 0,
        data["winner_side"]?.try(&.as_s?),
        data["complexity_score"]?.try(&.as_s?),
        data["turns_played"]?.try(&.as_s?),
        data["duration_seconds"]?.try(&.as_s?),
        data["ended_by"]?.try(&.as_s?),
        data["replay_url"]?.try(&.as_s?),
        data["match_id"]?.try(&.as_i64?),
        data["winner_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM games WHERE id = ?", id, as: Game)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    post "/api/games/{id}/winner" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement record_winner behavior
      {result: "ok"}.to_json
    end

    get "/api/games/{id}/duration" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement duration_minutes behavior
      {result: "ok"}.to_json
    end

  end
  def self.tournament_prize_routes
    get "/api/tournament_prizes" do |env|
      rows = AppDB.query_all("SELECT * FROM tournament_prizes", as: TournamentPrize)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/tournament_prizes/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM tournament_prizes WHERE id = ?", id, as: TournamentPrize)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/tournament_prizes" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO tournament_prizes (placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        data["placement_from"]?.try(&.as_i?) || 0,
        data["placement_to"]?.try(&.as_i?) || 0,
        data["prize_type"]?.try(&.as_s) || "",
        data["amount"]?.try(&.as_f?) || 0.0,
        data["description"]?.try(&.as_s?),
        data["packs_count"]?.try(&.as_s?),
        data["season_points"]?.try(&.as_i?) || 0,
        data["tournament_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM tournament_prizes WHERE id = ?", id, as: TournamentPrize)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/tournament_prizes/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE tournament_prizes SET placement_from = ?, placement_to = ?, prize_type = ?, amount = ?, description = ?, packs_count = ?, season_points = ?, tournament_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["placement_from"]?.try(&.as_i?) || 0,
        data["placement_to"]?.try(&.as_i?) || 0,
        data["prize_type"]?.try(&.as_s) || "",
        data["amount"]?.try(&.as_f?) || 0.0,
        data["description"]?.try(&.as_s?),
        data["packs_count"]?.try(&.as_i?) || 0,
        data["season_points"]?.try(&.as_i?) || 0,
        data["tournament_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM tournament_prizes WHERE id = ?", id, as: TournamentPrize)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/tournament_prizes/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("placement_from")
        updates << "placement_from = ?"
        values << data["placement_from"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("placement_to")
        updates << "placement_to = ?"
        values << data["placement_to"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("prize_type")
        updates << "prize_type = ?"
        values << data["prize_type"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("amount")
        updates << "amount = ?"
        values << data["amount"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("description")
        updates << "description = ?"
        values << data["description"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("packs_count")
        updates << "packs_count = ?"
        values << data["packs_count"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("season_points")
        updates << "season_points = ?"
        values << data["season_points"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("tournament_id")
        updates << "tournament_id = ?"
        values << data["tournament_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE tournament_prizes SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM tournament_prizes WHERE id = ?", id, as: TournamentPrize)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    delete "/api/tournament_prizes/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM tournament_prizes WHERE id = ?", id)
      env.response.status_code = 204
    end

    get "/api/prizes/{id}/applies" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement applies_to_placement behavior
      {result: "ok"}.to_json
    end

    post "/api/prizes/{id}/award" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement award_to_player behavior
      {result: "ok"}.to_json
    end

  end
  def self.awarded_prize_routes
    get "/api/awarded_prizes" do |env|
      rows = AppDB.query_all("SELECT * FROM awarded_prizes", as: AwardedPrize)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/awarded_prizes/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM awarded_prizes WHERE id = ?", id, as: AwardedPrize)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/awarded-prizes/{id}/claim" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement claim behavior
      {result: "ok"}.to_json
    end

  end
end
