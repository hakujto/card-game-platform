require "kemal"
require "../models/players"
require "../db"

module PlayersRoutes
  def self.player_routes
    get "/api/players" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM players WHERE display_name LIKE ?", "%#{q}%", as: Player)
      else
        AppDB.query_all("SELECT * FROM players", as: Player)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/players/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM players WHERE id = ?", id, as: Player)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/players" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO players (public_id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, contact_email, win_rate_cached, is_verified, last_active_at, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["public_id"]?.try(&.as_s) || "",
        data["display_name"]?.try(&.as_s) || "",
        data["rank"]?.try(&.as_s) || "Bronze",
        data["rating"]?.try(&.as_i?) || 1000,
        data["peak_rating"]?.try(&.as_i?) || 1000,
        data["bio"]?.try(&.as_s?),
        data["country_code"]?.try(&.as_s?),
        data["avatar_url"]?.try(&.as_s?),
        data["preferred_format"]?.try(&.as_s?),
        data["contact_email"]?.try(&.as_s?),
        data["win_rate_cached"]?.try(&.as_s?),
        data["is_verified"]?.try(&.as_bool?) || false,
        data["lastActiveAt"]?.try(&.as_s?),
        data["user_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM players WHERE id = ?", id, as: Player)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    patch "/api/players/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("public_id")
        updates << "public_id = ?"
        values << data["public_id"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("display_name")
        updates << "display_name = ?"
        values << data["display_name"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("rank")
        updates << "rank = ?"
        values << data["rank"]?.try(&.as_s) || "Bronze"
      end
      if data.as_h.has_key?("bio")
        updates << "bio = ?"
        values << data["bio"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("country_code")
        updates << "country_code = ?"
        values << data["country_code"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("avatar_url")
        updates << "avatar_url = ?"
        values << data["avatar_url"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("preferred_format")
        updates << "preferred_format = ?"
        values << data["preferred_format"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("contact_email")
        updates << "contact_email = ?"
        values << data["contact_email"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("win_rate_cached")
        updates << "win_rate_cached = ?"
        values << data["win_rate_cached"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("is_verified")
        updates << "is_verified = ?"
        values << data["is_verified"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("lastActiveAt")
        updates << "last_active_at = ?"
        values << data["lastActiveAt"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("user_id")
        updates << "user_id = ?"
        values << data["user_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE players SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM players WHERE id = ?", id, as: Player)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/players/{id}/promote" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement promote behavior
      {result: "ok"}.to_json
    end

    post "/api/players/{id}/demote" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement demote behavior
      {result: "ok"}.to_json
    end

    post "/api/players/{id}/win" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement record_win behavior
      {result: "ok"}.to_json
    end

    post "/api/players/{id}/loss" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement record_loss behavior
      {result: "ok"}.to_json
    end

    get "/api/players/{id}/win-rate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement win_rate behavior
      {result: "ok"}.to_json
    end

    post "/api/players/{id}/verify" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement verify behavior
      {result: "ok"}.to_json
    end

    patch "/api/players/{id}/rating" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement update_rating behavior
      {result: "ok"}.to_json
    end

  end
  def self.player_season_stats_routes
    get "/api/player_season_statses" do |env|
      rows = AppDB.query_all("SELECT * FROM player_season_statses", as: PlayerSeasonStats)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/player_season_statses/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM player_season_statses WHERE id = ?", id, as: PlayerSeasonStats)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    get "/api/player-season-stats/{id}/win-rate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement win_rate behavior
      {result: "ok"}.to_json
    end

    patch "/api/player-season-stats/{id}/points" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement add_points behavior
      {result: "ok"}.to_json
    end

    post "/api/player-season-stats/{id}/tournament-win" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement record_tournament_win behavior
      {result: "ok"}.to_json
    end

  end
  def self.player_collection_routes
    get "/api/player_collections" do |env|
      rows = AppDB.query_all("SELECT * FROM player_collections", as: PlayerCollection)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/player_collections/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM player_collections WHERE id = ?", id, as: PlayerCollection)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/player_collections" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO player_collections (quantity, foil, condition, acquired_at, acquired_via, player_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
        data["quantity"]?.try(&.as_i?) || 1,
        data["foil"]?.try(&.as_bool?) || false,
        data["condition"]?.try(&.as_s) || "Mint",
        data["acquiredAt"]?.try(&.as_s) || "",
        data["acquired_via"]?.try(&.as_s) || "Purchase",
        data["player_id"]?.try(&.as_i64?),
        data["card_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM player_collections WHERE id = ?", id, as: PlayerCollection)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    patch "/api/player_collections/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("quantity")
        updates << "quantity = ?"
        values << data["quantity"]?.try(&.as_i?) || 1
      end
      if data.as_h.has_key?("foil")
        updates << "foil = ?"
        values << data["foil"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("condition")
        updates << "condition = ?"
        values << data["condition"]?.try(&.as_s) || "Mint"
      end
      if data.as_h.has_key?("acquiredAt")
        updates << "acquired_at = ?"
        values << data["acquiredAt"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("acquired_via")
        updates << "acquired_via = ?"
        values << data["acquired_via"]?.try(&.as_s) || "Purchase"
      end
      if data.as_h.has_key?("player_id")
        updates << "player_id = ?"
        values << data["player_id"]?.try(&.as_i64?)
      end
      if data.as_h.has_key?("card_id")
        updates << "card_id = ?"
        values << data["card_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE player_collections SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM player_collections WHERE id = ?", id, as: PlayerCollection)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    delete "/api/player_collections/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM player_collections WHERE id = ?", id)
      env.response.status_code = 204
    end

    post "/api/collection/{id}/add" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement add behavior
      {result: "ok"}.to_json
    end

    post "/api/collection/{id}/remove" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement remove behavior
      {result: "ok"}.to_json
    end

    get "/api/collection/{id}/value" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement estimated_value behavior
      {result: "ok"}.to_json
    end

  end
  def self.friendship_routes
    get "/api/friendships" do |env|
      rows = AppDB.query_all("SELECT * FROM friendships", as: Friendship)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/friendships/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM friendships WHERE id = ?", id, as: Friendship)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/friendships" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO friendships (status, requester_id, receiver_id) VALUES (?, ?, ?)",
        data["status"]?.try(&.as_s) || "Pending",
        data["requester_id"]?.try(&.as_i64?),
        data["receiver_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM friendships WHERE id = ?", id, as: Friendship)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/friendships/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM friendships WHERE id = ?", id)
      env.response.status_code = 204
    end

    post "/api/friendships/{id}/accept" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement accept behavior
      {result: "ok"}.to_json
    end

    post "/api/friendships/{id}/decline" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement decline behavior
      {result: "ok"}.to_json
    end

    post "/api/friendships/{id}/block" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement block behavior
      {result: "ok"}.to_json
    end

  end
  def self.achievement_routes
    get "/api/achievements" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM achievements WHERE name LIKE ?", "%#{q}%", as: Achievement)
      else
        AppDB.query_all("SELECT * FROM achievements", as: Achievement)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/achievements/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM achievements WHERE id = ?", id, as: Achievement)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/achievements" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO achievements (name, description, icon_url, points, rarity, is_hidden) VALUES (?, ?, ?, ?, ?, ?)",
        data["name"]?.try(&.as_s) || "",
        data["description"]?.try(&.as_s) || "",
        data["icon_url"]?.try(&.as_s?),
        data["points"]?.try(&.as_i?) || 10,
        data["rarity"]?.try(&.as_s) || "Common",
        data["is_hidden"]?.try(&.as_bool?) || false
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM achievements WHERE id = ?", id, as: Achievement)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/achievements/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE achievements SET name = ?, description = ?, icon_url = ?, points = ?, rarity = ?, is_hidden = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["name"]?.try(&.as_s) || "",
        data["description"]?.try(&.as_s) || "",
        data["icon_url"]?.try(&.as_s?),
        data["points"]?.try(&.as_i?) || 10,
        data["rarity"]?.try(&.as_s) || "Common",
        data["is_hidden"]?.try(&.as_bool?) || false,
        id
      )
      row = AppDB.query_one?("SELECT * FROM achievements WHERE id = ?", id, as: Achievement)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/achievements/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("name")
        updates << "name = ?"
        values << data["name"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("description")
        updates << "description = ?"
        values << data["description"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("icon_url")
        updates << "icon_url = ?"
        values << data["icon_url"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("points")
        updates << "points = ?"
        values << data["points"]?.try(&.as_i?) || 10
      end
      if data.as_h.has_key?("rarity")
        updates << "rarity = ?"
        values << data["rarity"]?.try(&.as_s) || "Common"
      end
      if data.as_h.has_key?("is_hidden")
        updates << "is_hidden = ?"
        values << data["is_hidden"]?.try(&.as_bool?) || false
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE achievements SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM achievements WHERE id = ?", id, as: Achievement)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    get "/api/achievements/{id}/point-value" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement point_value behavior
      {result: "ok"}.to_json
    end

    post "/api/achievements/{id}/reveal" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement reveal behavior
      {result: "ok"}.to_json
    end

  end
  def self.player_achievement_routes
    get "/api/player_achievements" do |env|
      rows = AppDB.query_all("SELECT * FROM player_achievements", as: PlayerAchievement)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/player_achievements/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM player_achievements WHERE id = ?", id, as: PlayerAchievement)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/player-achievements/{id}/progress" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement increment_progress behavior
      {result: "ok"}.to_json
    end

    post "/api/player-achievements/{id}/complete" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement complete behavior
      {result: "ok"}.to_json
    end

  end
  def self.crafting_recipe_routes
    get "/api/crafting_recipes" do |env|
      rows = AppDB.query_all("SELECT * FROM crafting_recipes", as: CraftingRecipe)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/crafting_recipes/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM crafting_recipes WHERE id = ?", id, as: CraftingRecipe)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/crafting_recipes" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO crafting_recipes (dust_cost, is_available, result_card_id) VALUES (?, ?, ?)",
        data["dust_cost"]?.try(&.as_i?) || 0,
        data["is_available"]?.try(&.as_bool?) || true,
        data["result_card_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM crafting_recipes WHERE id = ?", id, as: CraftingRecipe)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/crafting_recipes/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE crafting_recipes SET dust_cost = ?, is_available = ?, result_card_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["dust_cost"]?.try(&.as_i?) || 0,
        data["is_available"]?.try(&.as_bool?) || true,
        data["result_card_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM crafting_recipes WHERE id = ?", id, as: CraftingRecipe)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/crafting_recipes/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("dust_cost")
        updates << "dust_cost = ?"
        values << data["dust_cost"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("is_available")
        updates << "is_available = ?"
        values << data["is_available"]?.try(&.as_bool?) || true
      end
      if data.as_h.has_key?("result_card_id")
        updates << "result_card_id = ?"
        values << data["result_card_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE crafting_recipes SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM crafting_recipes WHERE id = ?", id, as: CraftingRecipe)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    get "/api/crafting-recipes/{id}/can-craft" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement can_craft behavior
      {result: "ok"}.to_json
    end

    post "/api/crafting-recipes/{id}/craft" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement execute_craft behavior
      {result: "ok"}.to_json
    end

    post "/api/crafting-recipes/{id}/disable" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement disable behavior
      {result: "ok"}.to_json
    end

    post "/api/crafting-recipes/{id}/enable" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement enable behavior
      {result: "ok"}.to_json
    end

  end
  def self.crafting_ingredient_routes
    get "/api/crafting_ingredients" do |env|
      rows = AppDB.query_all("SELECT * FROM crafting_ingredients", as: CraftingIngredient)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/crafting_ingredients/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM crafting_ingredients WHERE id = ?", id, as: CraftingIngredient)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/crafting_ingredients" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO crafting_ingredients (quantity, recipe_id, card_id) VALUES (?, ?, ?)",
        data["quantity"]?.try(&.as_i?) || 1,
        data["recipe_id"]?.try(&.as_i64?),
        data["card_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM crafting_ingredients WHERE id = ?", id, as: CraftingIngredient)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/crafting_ingredients/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM crafting_ingredients WHERE id = ?", id)
      env.response.status_code = 204
    end

  end
end
