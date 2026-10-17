require "kemal"
require "../models/cards"
require "../db"

module CardsRoutes
  def self.card_routes
    get "/api/cards" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM cards WHERE name LIKE ?", "%#{q}%", as: Card)
      else
        AppDB.query_all("SELECT * FROM cards", as: Card)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/cards/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM cards WHERE id = ?", id, as: Card)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/cards" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO cards (public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["public_id"]?.try(&.as_s) || "",
        data["name"]?.try(&.as_s) || "",
        data["card_type"]?.try(&.as_s) || "Creature",
        data["rarity"]?.try(&.as_s) || "Common",
        data["mana_cost"]?.try(&.as_i?) || 0,
        data["mana_colors"]?.try(&.to_json),
        data["attack"]?.try(&.as_s?),
        data["defense"]?.try(&.as_s?),
        data["loyalty"]?.try(&.as_s?),
        data["description"]?.try(&.as_s) || "",
        data["flavor_text"]?.try(&.as_s?),
        data["image_url"]?.try(&.as_s?),
        data["artist_name"]?.try(&.as_s?),
        data["legal_formats"]?.try(&.to_json),
        data["is_banned"]?.try(&.as_bool?) || false,
        data["is_restricted"]?.try(&.as_bool?) || false,
        data["power_level"]?.try(&.as_i?) || 1,
        data["metadata"]?.try(&.to_json),
        data["total_copies_in_circulation"]?.try(&.as_i?) || 0,
        data["set_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM cards WHERE id = ?", id, as: Card)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/cards/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE cards SET public_id = ?, name = ?, card_type = ?, rarity = ?, mana_cost = ?, mana_colors = ?, attack = ?, defense = ?, loyalty = ?, description = ?, flavor_text = ?, image_url = ?, artist_name = ?, legal_formats = ?, power_level = ?, metadata = ?, total_copies_in_circulation = ?, set_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["public_id"]?.try(&.as_s) || "",
        data["name"]?.try(&.as_s) || "",
        data["card_type"]?.try(&.as_s) || "Creature",
        data["rarity"]?.try(&.as_s) || "Common",
        data["mana_cost"]?.try(&.as_i?) || 0,
        data["mana_colors"]?.try(&.to_json),
        data["attack"]?.try(&.as_i?) || 0,
        data["defense"]?.try(&.as_i?) || 0,
        data["loyalty"]?.try(&.as_i?) || 0,
        data["description"]?.try(&.as_s) || "",
        data["flavor_text"]?.try(&.as_s?),
        data["image_url"]?.try(&.as_s?),
        data["artist_name"]?.try(&.as_s?),
        data["legal_formats"]?.try(&.to_json),
        data["power_level"]?.try(&.as_i?) || 1,
        data["metadata"]?.try(&.to_json),
        data["total_copies_in_circulation"]?.try(&.as_i?) || 0,
        data["set_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM cards WHERE id = ?", id, as: Card)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/cards/:id" do |env|
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
      if data.as_h.has_key?("card_type")
        updates << "card_type = ?"
        values << data["card_type"]?.try(&.as_s) || "Creature"
      end
      if data.as_h.has_key?("rarity")
        updates << "rarity = ?"
        values << data["rarity"]?.try(&.as_s) || "Common"
      end
      if data.as_h.has_key?("mana_cost")
        updates << "mana_cost = ?"
        values << data["mana_cost"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("mana_colors")
        updates << "mana_colors = ?"
        values << data["mana_colors"]?.try(&.to_json)
      end
      if data.as_h.has_key?("attack")
        updates << "attack = ?"
        values << data["attack"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("defense")
        updates << "defense = ?"
        values << data["defense"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("loyalty")
        updates << "loyalty = ?"
        values << data["loyalty"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("description")
        updates << "description = ?"
        values << data["description"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("flavor_text")
        updates << "flavor_text = ?"
        values << data["flavor_text"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("image_url")
        updates << "image_url = ?"
        values << data["image_url"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("artist_name")
        updates << "artist_name = ?"
        values << data["artist_name"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("legal_formats")
        updates << "legal_formats = ?"
        values << data["legal_formats"]?.try(&.to_json)
      end
      if data.as_h.has_key?("power_level")
        updates << "power_level = ?"
        values << data["power_level"]?.try(&.as_i?) || 1
      end
      if data.as_h.has_key?("metadata")
        updates << "metadata = ?"
        values << data["metadata"]?.try(&.to_json)
      end
      if data.as_h.has_key?("total_copies_in_circulation")
        updates << "total_copies_in_circulation = ?"
        values << data["total_copies_in_circulation"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("set_id")
        updates << "set_id = ?"
        values << data["set_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE cards SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM cards WHERE id = ?", id, as: Card)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/cards/{id}/ban" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement ban behavior
      {result: "ok"}.to_json
    end

    post "/api/cards/{id}/unban" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement unban behavior
      {result: "ok"}.to_json
    end

    post "/api/cards/{id}/restrict" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement restrict behavior
      {result: "ok"}.to_json
    end

    post "/api/cards/{id}/unrestrict" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement unrestrict behavior
      {result: "ok"}.to_json
    end

    put "/api/cards/{id}" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement replace behavior
      {result: "ok"}.to_json
    end

    get "/api/cards/{id}/value" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement calculate_value behavior
      {result: "ok"}.to_json
    end

    post "/api/cards/{id}/rarity-bonus" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement apply_rarity_bonus behavior
      {result: "ok"}.to_json
    end

    get "/api/cards/{id}/legal" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_legal_in_format behavior
      {result: "ok"}.to_json
    end

  end
  def self.card_set_routes
    get "/api/card_sets" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM card_sets WHERE name LIKE ?", "%#{q}%", as: CardSet)
      else
        AppDB.query_all("SELECT * FROM card_sets", as: CardSet)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/card_sets/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM card_sets WHERE id = ?", id, as: CardSet)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/card_sets" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO card_sets (name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["name"]?.try(&.as_s) || "",
        data["code"]?.try(&.as_s) || "",
        data["release_date"]?.try(&.as_s) || "",
        data["rotation_date"]?.try(&.as_s?),
        data["set_type"]?.try(&.as_s) || "Expansion",
        data["total_cards"]?.try(&.as_i?) || 0,
        data["is_rotated"]?.try(&.as_bool?) || false,
        data["description"]?.try(&.as_s?),
        data["logo_url"]?.try(&.as_s?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM card_sets WHERE id = ?", id, as: CardSet)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/card_sets/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE card_sets SET name = ?, code = ?, release_date = ?, rotation_date = ?, set_type = ?, total_cards = ?, is_rotated = ?, description = ?, logo_url = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["name"]?.try(&.as_s) || "",
        data["code"]?.try(&.as_s) || "",
        data["release_date"]?.try(&.as_s) || "",
        data["rotation_date"]?.try(&.as_s?),
        data["set_type"]?.try(&.as_s) || "Expansion",
        data["total_cards"]?.try(&.as_i?) || 0,
        data["is_rotated"]?.try(&.as_bool?) || false,
        data["description"]?.try(&.as_s?),
        data["logo_url"]?.try(&.as_s?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM card_sets WHERE id = ?", id, as: CardSet)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/card_sets/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("name")
        updates << "name = ?"
        values << data["name"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("code")
        updates << "code = ?"
        values << data["code"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("release_date")
        updates << "release_date = ?"
        values << data["release_date"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("rotation_date")
        updates << "rotation_date = ?"
        values << data["rotation_date"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("set_type")
        updates << "set_type = ?"
        values << data["set_type"]?.try(&.as_s) || "Expansion"
      end
      if data.as_h.has_key?("total_cards")
        updates << "total_cards = ?"
        values << data["total_cards"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("is_rotated")
        updates << "is_rotated = ?"
        values << data["is_rotated"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("description")
        updates << "description = ?"
        values << data["description"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("logo_url")
        updates << "logo_url = ?"
        values << data["logo_url"]?.try(&.as_s?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE card_sets SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM card_sets WHERE id = ?", id, as: CardSet)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    get "/api/card-sets/{id}/standard-legal" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_legal_in_standard behavior
      {result: "ok"}.to_json
    end

    get "/api/card-sets/{id}/legal" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_legal_in_format behavior
      {result: "ok"}.to_json
    end

    get "/api/card-sets/{id}/rarity-count" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement card_count_by_rarity behavior
      {result: "ok"}.to_json
    end

    post "/api/card-sets/{id}/rotate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement rotate_out behavior
      {result: "ok"}.to_json
    end

  end
  def self.card_ruling_routes
    get "/api/card_rulings" do |env|
      rows = AppDB.query_all("SELECT * FROM card_rulings", as: CardRuling)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/card_rulings/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM card_rulings WHERE id = ?", id, as: CardRuling)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/card_rulings" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO card_rulings (ruling_text, published_at, source, card_id) VALUES (?, ?, ?, ?)",
        data["ruling_text"]?.try(&.as_s) || "",
        data["published_at"]?.try(&.as_s) || "",
        data["source"]?.try(&.as_s) || "",
        data["card_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM card_rulings WHERE id = ?", id, as: CardRuling)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/card_rulings/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM card_rulings WHERE id = ?", id)
      env.response.status_code = 204
    end

    get "/api/card-rulings/{id}/current" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_current behavior
      {result: "ok"}.to_json
    end

    get "/api/card-rulings/{id}/supersedes" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement supersedes_previous behavior
      {result: "ok"}.to_json
    end

  end
  def self.card_ability_routes
    get "/api/card_abilities" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM card_abilities WHERE keyword LIKE ?", "%#{q}%", as: CardAbility)
      else
        AppDB.query_all("SELECT * FROM card_abilities", as: CardAbility)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/card_abilities/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM card_abilities WHERE id = ?", id, as: CardAbility)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/card_abilities" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO card_abilities (ability_type, keyword, ability_text, timing, card_id) VALUES (?, ?, ?, ?, ?)",
        data["ability_type"]?.try(&.as_s) || "Keyword",
        data["keyword"]?.try(&.as_s?),
        data["ability_text"]?.try(&.as_s) || "",
        data["timing"]?.try(&.as_s?),
        data["card_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM card_abilities WHERE id = ?", id, as: CardAbility)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/card_abilities/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE card_abilities SET ability_type = ?, keyword = ?, ability_text = ?, timing = ?, card_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["ability_type"]?.try(&.as_s) || "Keyword",
        data["keyword"]?.try(&.as_s?),
        data["ability_text"]?.try(&.as_s) || "",
        data["timing"]?.try(&.as_s?),
        data["card_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM card_abilities WHERE id = ?", id, as: CardAbility)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/card_abilities/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("ability_type")
        updates << "ability_type = ?"
        values << data["ability_type"]?.try(&.as_s) || "Keyword"
      end
      if data.as_h.has_key?("keyword")
        updates << "keyword = ?"
        values << data["keyword"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("ability_text")
        updates << "ability_text = ?"
        values << data["ability_text"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("timing")
        updates << "timing = ?"
        values << data["timing"]?.try(&.as_s?)
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
      AppDB.exec("UPDATE card_abilities SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM card_abilities WHERE id = ?", id, as: CardAbility)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    delete "/api/card_abilities/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM card_abilities WHERE id = ?", id)
      env.response.status_code = 204
    end

    get "/api/card-abilities/{id}/usable" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_usable_at behavior
      {result: "ok"}.to_json
    end

    get "/api/card-abilities/{id}/describe" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement describe behavior
      {result: "ok"}.to_json
    end

  end
  def self.deck_routes
    get "/api/decks" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM decks WHERE name LIKE ?", "%#{q}%", as: Deck)
      else
        AppDB.query_all("SELECT * FROM decks", as: Deck)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/decks/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM decks WHERE id = ?", id, as: Deck)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/decks" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["name"]?.try(&.as_s) || "",
        data["description"]?.try(&.as_s?),
        data["format"]?.try(&.as_s) || "Standard",
        data["is_public"]?.try(&.as_bool?) || false,
        data["is_tournament_legal"]?.try(&.as_bool?) || false,
        data["archetype"]?.try(&.as_s?),
        data["wins"]?.try(&.as_i?) || 0,
        data["losses"]?.try(&.as_i?) || 0,
        data["draws"]?.try(&.as_i?) || 0,
        data["player_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM decks WHERE id = ?", id, as: Deck)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/decks/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE decks SET name = ?, description = ?, format = ?, is_public = ?, is_tournament_legal = ?, archetype = ?, player_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["name"]?.try(&.as_s) || "",
        data["description"]?.try(&.as_s?),
        data["format"]?.try(&.as_s) || "Standard",
        data["is_public"]?.try(&.as_bool?) || false,
        data["is_tournament_legal"]?.try(&.as_bool?) || false,
        data["archetype"]?.try(&.as_s?),
        data["player_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM decks WHERE id = ?", id, as: Deck)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/decks/:id" do |env|
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
        values << data["description"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("format")
        updates << "format = ?"
        values << data["format"]?.try(&.as_s) || "Standard"
      end
      if data.as_h.has_key?("is_public")
        updates << "is_public = ?"
        values << data["is_public"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("is_tournament_legal")
        updates << "is_tournament_legal = ?"
        values << data["is_tournament_legal"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("archetype")
        updates << "archetype = ?"
        values << data["archetype"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("player_id")
        updates << "player_id = ?"
        values << data["player_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE decks SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM decks WHERE id = ?", id, as: Deck)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    delete "/api/decks/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM decks WHERE id = ?", id)
      env.response.status_code = 204
    end

    get "/api/decks/{id}/validate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement validate_size behavior
      {result: "ok"}.to_json
    end

    post "/api/decks/{id}/cards" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement add_card behavior
      {result: "ok"}.to_json
    end

    delete "/api/decks/{id}/cards/{card_id}" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement remove_card behavior
      {result: "ok"}.to_json
    end

    get "/api/decks/{id}/win-rate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement win_rate behavior
      {result: "ok"}.to_json
    end

    post "/api/decks/{id}/clone" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement clone behavior
      {result: "ok"}.to_json
    end

    post "/api/decks/{id}/publish" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement publish behavior
      {result: "ok"}.to_json
    end

    post "/api/decks/{id}/unpublish" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement unpublish behavior
      {result: "ok"}.to_json
    end

    post "/api/decks/{id}/certify" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement certify_tournament_legal behavior
      {result: "ok"}.to_json
    end

  end
  def self.deck_card_routes
    get "/api/deck_cards" do |env|
      rows = AppDB.query_all("SELECT * FROM deck_cards", as: DeckCard)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/deck_cards/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM deck_cards WHERE id = ?", id, as: DeckCard)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/deck_cards" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO deck_cards (quantity, is_commander, deck_id, card_id) VALUES (?, ?, ?, ?)",
        data["quantity"]?.try(&.as_i?) || 1,
        data["is_commander"]?.try(&.as_bool?) || false,
        data["deck_id"]?.try(&.as_i64?),
        data["card_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM deck_cards WHERE id = ?", id, as: DeckCard)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    patch "/api/deck_cards/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("quantity")
        updates << "quantity = ?"
        values << data["quantity"]?.try(&.as_i?) || 1
      end
      if data.as_h.has_key?("is_commander")
        updates << "is_commander = ?"
        values << data["is_commander"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("deck_id")
        updates << "deck_id = ?"
        values << data["deck_id"]?.try(&.as_i64?)
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
      AppDB.exec("UPDATE deck_cards SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM deck_cards WHERE id = ?", id, as: DeckCard)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    delete "/api/deck_cards/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM deck_cards WHERE id = ?", id)
      env.response.status_code = 204
    end

    patch "/api/deck-cards/{id}/increment" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement increment behavior
      {result: "ok"}.to_json
    end

    patch "/api/deck-cards/{id}/decrement" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement decrement behavior
      {result: "ok"}.to_json
    end

  end
  def self.deck_sideboard_card_routes
    get "/api/deck_sideboard_cards" do |env|
      rows = AppDB.query_all("SELECT * FROM deck_sideboard_cards", as: DeckSideboardCard)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/deck_sideboard_cards/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM deck_sideboard_cards WHERE id = ?", id, as: DeckSideboardCard)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/deck_sideboard_cards" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO deck_sideboard_cards (quantity, deck_id, card_id) VALUES (?, ?, ?)",
        data["quantity"]?.try(&.as_i?) || 1,
        data["deck_id"]?.try(&.as_i64?),
        data["card_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM deck_sideboard_cards WHERE id = ?", id, as: DeckSideboardCard)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    patch "/api/deck_sideboard_cards/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("quantity")
        updates << "quantity = ?"
        values << data["quantity"]?.try(&.as_i?) || 1
      end
      if data.as_h.has_key?("deck_id")
        updates << "deck_id = ?"
        values << data["deck_id"]?.try(&.as_i64?)
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
      AppDB.exec("UPDATE deck_sideboard_cards SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM deck_sideboard_cards WHERE id = ?", id, as: DeckSideboardCard)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    delete "/api/deck_sideboard_cards/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM deck_sideboard_cards WHERE id = ?", id)
      env.response.status_code = 204
    end

    patch "/api/sideboard-cards/{id}/increment" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement increment behavior
      {result: "ok"}.to_json
    end

    patch "/api/sideboard-cards/{id}/decrement" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement decrement behavior
      {result: "ok"}.to_json
    end

  end
  def self.deck_tag_routes
    get "/api/deck_tags" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM deck_tags WHERE name LIKE ?", "%#{q}%", as: DeckTag)
      else
        AppDB.query_all("SELECT * FROM deck_tags", as: DeckTag)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/deck_tags/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM deck_tags WHERE id = ?", id, as: DeckTag)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/deck_tags" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO deck_tags (name, slug, color) VALUES (?, ?, ?)",
        data["name"]?.try(&.as_s) || "",
        data["slug"]?.try(&.as_s?),
        data["color"]?.try(&.as_s?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM deck_tags WHERE id = ?", id, as: DeckTag)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    patch "/api/deck_tags/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("name")
        updates << "name = ?"
        values << data["name"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("slug")
        updates << "slug = ?"
        values << data["slug"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("color")
        updates << "color = ?"
        values << data["color"]?.try(&.as_s?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE deck_tags SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM deck_tags WHERE id = ?", id, as: DeckTag)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    delete "/api/deck_tags/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM deck_tags WHERE id = ?", id)
      env.response.status_code = 204
    end

    patch "/api/deck-tags/{id}/rename" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement rename behavior
      {result: "ok"}.to_json
    end

    post "/api/deck-tags/{id}/merge" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement merge_into behavior
      {result: "ok"}.to_json
    end

  end
  def self.deck_tag_assignment_routes
    get "/api/deck_tag_assignments" do |env|
      rows = AppDB.query_all("SELECT * FROM deck_tag_assignments", as: DeckTagAssignment)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/deck_tag_assignments/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM deck_tag_assignments WHERE id = ?", id, as: DeckTagAssignment)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/deck_tag_assignments" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO deck_tag_assignments (deck_id, tag_id) VALUES (?, ?)",
        data["deck_id"]?.try(&.as_i64?),
        data["tag_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM deck_tag_assignments WHERE id = ?", id, as: DeckTagAssignment)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/deck_tag_assignments/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM deck_tag_assignments WHERE id = ?", id)
      env.response.status_code = 204
    end

  end
end
