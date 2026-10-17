require "kemal"
require "../models/content"
require "../db"

module ContentRoutes
  def self.draft_session_routes
    get "/api/draft_sessions" do |env|
      rows = AppDB.query_all("SELECT * FROM draft_sessions", as: DraftSession)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/draft_sessions/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM draft_sessions WHERE id = ?", id, as: DraftSession)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/draft_sessions" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO draft_sessions (status, draft_type, pack_contents, seats, time_per_pick_seconds, completed_at, card_set_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
        data["status"]?.try(&.as_s) || "WaitingForPlayers",
        data["draft_type"]?.try(&.as_s) || "Booster",
        data["pack_contents"]?.try(&.to_json),
        data["seats"]?.try(&.as_i?) || 8,
        data["time_per_pick_seconds"]?.try(&.as_i?) || 30,
        data["completedAt"]?.try(&.as_s?),
        data["card_set_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM draft_sessions WHERE id = ?", id, as: DraftSession)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    post "/api/draft-sessions/{id}/start" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement start behavior
      {result: "ok"}.to_json
    end

    post "/api/draft-sessions/{id}/abandon" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement abandon behavior
      {result: "ok"}.to_json
    end

    post "/api/draft-sessions/{id}/complete" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement complete behavior
      {result: "ok"}.to_json
    end

    get "/api/draft-sessions/{id}/full" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_full behavior
      {result: "ok"}.to_json
    end

  end
  def self.draft_participant_routes
    get "/api/draft_participants" do |env|
      rows = AppDB.query_all("SELECT * FROM draft_participants", as: DraftParticipant)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/draft_participants/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM draft_participants WHERE id = ?", id, as: DraftParticipant)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/draft_participants" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO draft_participants (seat_number, joined_at, session_id, player_id) VALUES (?, ?, ?, ?)",
        data["seat_number"]?.try(&.as_i?) || 0,
        data["joinedAt"]?.try(&.as_s) || "",
        data["session_id"]?.try(&.as_i64?),
        data["player_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM draft_participants WHERE id = ?", id, as: DraftParticipant)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    post "/api/draft-participants/{id}/pick" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement pick_card behavior
      {result: "ok"}.to_json
    end

    get "/api/draft-participants/{id}/card-count" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement drafted_card_count behavior
      {result: "ok"}.to_json
    end

  end
  def self.draft_pick_routes
    get "/api/draft_picks" do |env|
      rows = AppDB.query_all("SELECT * FROM draft_picks", as: DraftPick)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/draft_picks/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM draft_picks WHERE id = ?", id, as: DraftPick)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    get "/api/draft-picks/{id}/first-pick" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_first_pick behavior
      {result: "ok"}.to_json
    end

  end
  def self.article_routes
    get "/api/articles" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM articles WHERE title LIKE ?", "%#{q}%", as: Article)
      else
        AppDB.query_all("SELECT * FROM articles", as: Article)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/articles/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM articles WHERE id = ?", id, as: Article)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/articles" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO articles (title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["title"]?.try(&.as_s) || "",
        data["slug"]?.try(&.as_s) || "",
        data["body"]?.try(&.as_s) || "",
        data["excerpt"]?.try(&.as_s?),
        data["cover_image_url"]?.try(&.as_s?),
        data["status"]?.try(&.as_s) || "Draft",
        data["article_type"]?.try(&.as_s) || "Guide",
        data["language"]?.try(&.as_s) || "EN",
        data["view_count"]?.try(&.as_i?) || 0,
        data["likes_count"]?.try(&.as_i?) || 0,
        data["total_views_alltime"]?.try(&.as_i?) || 0,
        data["is_featured"]?.try(&.as_bool?) || false,
        data["publishedAt"]?.try(&.as_s?),
        data["author_id"]?.try(&.as_i64?),
        data["featured_deck_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM articles WHERE id = ?", id, as: Article)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/articles/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE articles SET title = ?, slug = ?, body = ?, excerpt = ?, cover_image_url = ?, article_type = ?, language = ?, total_views_alltime = ?, is_featured = ?, published_at = ?, author_id = ?, featured_deck_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["title"]?.try(&.as_s) || "",
        data["slug"]?.try(&.as_s) || "",
        data["body"]?.try(&.as_s) || "",
        data["excerpt"]?.try(&.as_s?),
        data["cover_image_url"]?.try(&.as_s?),
        data["article_type"]?.try(&.as_s) || "Guide",
        data["language"]?.try(&.as_s) || "EN",
        data["total_views_alltime"]?.try(&.as_i?) || 0,
        data["is_featured"]?.try(&.as_bool?) || false,
        data["publishedAt"]?.try(&.as_s?),
        data["author_id"]?.try(&.as_i64?),
        data["featured_deck_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM articles WHERE id = ?", id, as: Article)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/articles/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("title")
        updates << "title = ?"
        values << data["title"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("slug")
        updates << "slug = ?"
        values << data["slug"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("body")
        updates << "body = ?"
        values << data["body"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("excerpt")
        updates << "excerpt = ?"
        values << data["excerpt"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("cover_image_url")
        updates << "cover_image_url = ?"
        values << data["cover_image_url"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("article_type")
        updates << "article_type = ?"
        values << data["article_type"]?.try(&.as_s) || "Guide"
      end
      if data.as_h.has_key?("language")
        updates << "language = ?"
        values << data["language"]?.try(&.as_s) || "EN"
      end
      if data.as_h.has_key?("total_views_alltime")
        updates << "total_views_alltime = ?"
        values << data["total_views_alltime"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("is_featured")
        updates << "is_featured = ?"
        values << data["is_featured"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("publishedAt")
        updates << "published_at = ?"
        values << data["publishedAt"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("author_id")
        updates << "author_id = ?"
        values << data["author_id"]?.try(&.as_i64?)
      end
      if data.as_h.has_key?("featured_deck_id")
        updates << "featured_deck_id = ?"
        values << data["featured_deck_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE articles SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM articles WHERE id = ?", id, as: Article)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/articles/{id}/publish" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement publish behavior
      {result: "ok"}.to_json
    end

    post "/api/articles/{id}/archive" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement archive behavior
      {result: "ok"}.to_json
    end

    put "/api/articles/{id}" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement replace behavior
      {result: "ok"}.to_json
    end

    post "/api/articles/{id}/view" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement increment_view behavior
      {result: "ok"}.to_json
    end

    post "/api/articles/{id}/like" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement like behavior
      {result: "ok"}.to_json
    end

    delete "/api/articles/{id}/like" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement unlike behavior
      {result: "ok"}.to_json
    end

    get "/api/articles/{id}/reading-time" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement reading_time_minutes behavior
      {result: "ok"}.to_json
    end

  end
  def self.article_tag_routes
    get "/api/article_tags" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM article_tags WHERE name LIKE ?", "%#{q}%", as: ArticleTag)
      else
        AppDB.query_all("SELECT * FROM article_tags", as: ArticleTag)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/article_tags/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM article_tags WHERE id = ?", id, as: ArticleTag)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/article_tags" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO article_tags (name, slug) VALUES (?, ?)",
        data["name"]?.try(&.as_s) || "",
        data["slug"]?.try(&.as_s) || ""
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM article_tags WHERE id = ?", id, as: ArticleTag)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    patch "/api/article_tags/:id" do |env|
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
        values << data["slug"]?.try(&.as_s) || ""
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE article_tags SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM article_tags WHERE id = ?", id, as: ArticleTag)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    delete "/api/article_tags/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM article_tags WHERE id = ?", id)
      env.response.status_code = 204
    end

    patch "/api/article-tags/{id}/rename" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement rename behavior
      {result: "ok"}.to_json
    end

    get "/api/article-tags/{id}/article-count" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement article_count behavior
      {result: "ok"}.to_json
    end

  end
  def self.article_tag_assignment_routes
    get "/api/article_tag_assignments" do |env|
      rows = AppDB.query_all("SELECT * FROM article_tag_assignments", as: ArticleTagAssignment)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/article_tag_assignments/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM article_tag_assignments WHERE id = ?", id, as: ArticleTagAssignment)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/article_tag_assignments" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO article_tag_assignments (article_id, tag_id) VALUES (?, ?)",
        data["article_id"]?.try(&.as_i64?),
        data["tag_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM article_tag_assignments WHERE id = ?", id, as: ArticleTagAssignment)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/article_tag_assignments/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM article_tag_assignments WHERE id = ?", id)
      env.response.status_code = 204
    end

  end
  def self.article_comment_routes
    get "/api/article_comments" do |env|
      rows = AppDB.query_all("SELECT * FROM article_comments", as: ArticleComment)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/article_comments/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM article_comments WHERE id = ?", id, as: ArticleComment)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/article_comments" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO article_comments (body, is_hidden, article_id, author_id, parent_comment_id) VALUES (?, ?, ?, ?, ?)",
        data["body"]?.try(&.as_s) || "",
        data["is_hidden"]?.try(&.as_bool?) || false,
        data["article_id"]?.try(&.as_i64?),
        data["author_id"]?.try(&.as_i64?),
        data["parent_comment_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM article_comments WHERE id = ?", id, as: ArticleComment)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/article_comments/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM article_comments WHERE id = ?", id)
      env.response.status_code = 204
    end

    post "/api/comments/{id}/hide" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement hide behavior
      {result: "ok"}.to_json
    end

    post "/api/comments/{id}/unhide" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement unhide behavior
      {result: "ok"}.to_json
    end

    get "/api/comments/{id}/is-reply" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_reply behavior
      {result: "ok"}.to_json
    end

  end
  def self.stream_routes
    get "/api/streams" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM streams WHERE title LIKE ?", "%#{q}%", as: Stream)
      else
        AppDB.query_all("SELECT * FROM streams", as: Stream)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/streams/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM streams WHERE id = ?", id, as: Stream)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/streams" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO streams (title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["title"]?.try(&.as_s) || "",
        data["stream_url"]?.try(&.as_s) || "",
        data["status"]?.try(&.as_s) || "Scheduled",
        data["platform"]?.try(&.as_s) || "Twitch",
        data["language"]?.try(&.as_s) || "EN",
        data["is_official"]?.try(&.as_bool?) || false,
        data["viewer_count_peak"]?.try(&.as_i?) || 0,
        data["scheduledStart"]?.try(&.as_s) || "",
        data["actualStart"]?.try(&.as_s?),
        data["endedAt"]?.try(&.as_s?),
        data["vod_url"]?.try(&.as_s?),
        data["tournament_id"]?.try(&.as_i64?),
        data["streamer_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM streams WHERE id = ?", id, as: Stream)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/streams/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE streams SET title = ?, stream_url = ?, status = ?, platform = ?, language = ?, is_official = ?, viewer_count_peak = ?, scheduled_start = ?, actual_start = ?, ended_at = ?, vod_url = ?, tournament_id = ?, streamer_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["title"]?.try(&.as_s) || "",
        data["stream_url"]?.try(&.as_s) || "",
        data["status"]?.try(&.as_s) || "Scheduled",
        data["platform"]?.try(&.as_s) || "Twitch",
        data["language"]?.try(&.as_s) || "EN",
        data["is_official"]?.try(&.as_bool?) || false,
        data["viewer_count_peak"]?.try(&.as_i?) || 0,
        data["scheduledStart"]?.try(&.as_s) || "",
        data["actualStart"]?.try(&.as_s?),
        data["endedAt"]?.try(&.as_s?),
        data["vod_url"]?.try(&.as_s?),
        data["tournament_id"]?.try(&.as_i64?),
        data["streamer_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM streams WHERE id = ?", id, as: Stream)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/streams/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("title")
        updates << "title = ?"
        values << data["title"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("stream_url")
        updates << "stream_url = ?"
        values << data["stream_url"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("status")
        updates << "status = ?"
        values << data["status"]?.try(&.as_s) || "Scheduled"
      end
      if data.as_h.has_key?("platform")
        updates << "platform = ?"
        values << data["platform"]?.try(&.as_s) || "Twitch"
      end
      if data.as_h.has_key?("language")
        updates << "language = ?"
        values << data["language"]?.try(&.as_s) || "EN"
      end
      if data.as_h.has_key?("is_official")
        updates << "is_official = ?"
        values << data["is_official"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("viewer_count_peak")
        updates << "viewer_count_peak = ?"
        values << data["viewer_count_peak"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("scheduledStart")
        updates << "scheduled_start = ?"
        values << data["scheduledStart"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("actualStart")
        updates << "actual_start = ?"
        values << data["actualStart"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("endedAt")
        updates << "ended_at = ?"
        values << data["endedAt"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("vod_url")
        updates << "vod_url = ?"
        values << data["vod_url"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("tournament_id")
        updates << "tournament_id = ?"
        values << data["tournament_id"]?.try(&.as_i64?)
      end
      if data.as_h.has_key?("streamer_id")
        updates << "streamer_id = ?"
        values << data["streamer_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE streams SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM streams WHERE id = ?", id, as: Stream)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/streams/{id}/live" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement go_live behavior
      {result: "ok"}.to_json
    end

    post "/api/streams/{id}/end" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement end behavior
      {result: "ok"}.to_json
    end

    patch "/api/streams/{id}/viewers" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement update_viewer_peak behavior
      {result: "ok"}.to_json
    end

    get "/api/streams/{id}/duration" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement duration_minutes behavior
      {result: "ok"}.to_json
    end

  end
end
