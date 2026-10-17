require "kemal"
require "../models/marketplace"
require "../db"

module MarketplaceRoutes
  def self.product_routes
    get "/api/products" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM products WHERE name LIKE ?", "%#{q}%", as: Product)
      else
        AppDB.query_all("SELECT * FROM products", as: Product)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/products/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM products WHERE id = ?", id, as: Product)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/products" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO products (name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["name"]?.try(&.as_s) || "",
        data["product_type"]?.try(&.as_s) || "SingleCard",
        data["price"]?.try(&.as_f?) || 0.0,
        data["stock"]?.try(&.as_i?) || 0,
        data["active"]?.try(&.as_bool?) || true,
        data["discount_percent"]?.try(&.as_i?) || 0,
        data["description"]?.try(&.as_s?),
        data["image_url"]?.try(&.as_s?),
        data["featured"]?.try(&.as_bool?) || false,
        data["card_id"]?.try(&.as_i64?),
        data["card_set_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM products WHERE id = ?", id, as: Product)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/products/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE products SET name = ?, product_type = ?, price = ?, stock = ?, active = ?, discount_percent = ?, description = ?, image_url = ?, featured = ?, card_id = ?, card_set_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["name"]?.try(&.as_s) || "",
        data["product_type"]?.try(&.as_s) || "SingleCard",
        data["price"]?.try(&.as_f?) || 0.0,
        data["stock"]?.try(&.as_i?) || 0,
        data["active"]?.try(&.as_bool?) || true,
        data["discount_percent"]?.try(&.as_i?) || 0,
        data["description"]?.try(&.as_s?),
        data["image_url"]?.try(&.as_s?),
        data["featured"]?.try(&.as_bool?) || false,
        data["card_id"]?.try(&.as_i64?),
        data["card_set_id"]?.try(&.as_i64?),
        id
      )
      row = AppDB.query_one?("SELECT * FROM products WHERE id = ?", id, as: Product)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/products/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("name")
        updates << "name = ?"
        values << data["name"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("product_type")
        updates << "product_type = ?"
        values << data["product_type"]?.try(&.as_s) || "SingleCard"
      end
      if data.as_h.has_key?("price")
        updates << "price = ?"
        values << data["price"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("stock")
        updates << "stock = ?"
        values << data["stock"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("active")
        updates << "active = ?"
        values << data["active"]?.try(&.as_bool?) || true
      end
      if data.as_h.has_key?("discount_percent")
        updates << "discount_percent = ?"
        values << data["discount_percent"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("description")
        updates << "description = ?"
        values << data["description"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("image_url")
        updates << "image_url = ?"
        values << data["image_url"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("featured")
        updates << "featured = ?"
        values << data["featured"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("card_id")
        updates << "card_id = ?"
        values << data["card_id"]?.try(&.as_i64?)
      end
      if data.as_h.has_key?("card_set_id")
        updates << "card_set_id = ?"
        values << data["card_set_id"]?.try(&.as_i64?)
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE products SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM products WHERE id = ?", id, as: Product)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/products/{id}/activate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement activate behavior
      {result: "ok"}.to_json
    end

    post "/api/products/{id}/deactivate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement deactivate behavior
      {result: "ok"}.to_json
    end

    patch "/api/products/{id}/discount" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement apply_discount behavior
      {result: "ok"}.to_json
    end

    post "/api/products/{id}/restock" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement restock behavior
      {result: "ok"}.to_json
    end

    get "/api/products/{id}/effective-price" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement effective_price behavior
      {result: "ok"}.to_json
    end

    get "/api/products/{id}/in-stock" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_in_stock behavior
      {result: "ok"}.to_json
    end

  end
  def self.order_routes
    get "/api/orders" do |env|
      rows = AppDB.query_all("SELECT * FROM orders", as: Order)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/orders/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM orders WHERE id = ?", id, as: Order)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/orders" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO orders (status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["status"]?.try(&.as_s) || "Pending",
        data["total"]?.try(&.as_f?) || 0.0,
        data["discount_applied"]?.try(&.as_f?) || 0.0,
        data["currency"]?.try(&.as_s) || "USD",
        data["payment_method"]?.try(&.as_s?),
        data["payment_reference"]?.try(&.as_s?),
        data["shipping_address"]?.try(&.as_s?),
        data["tracking_number"]?.try(&.as_s?),
        data["paidAt"]?.try(&.as_s?),
        data["shippedAt"]?.try(&.as_s?),
        data["player_id"]?.try(&.as_i64?),
        data["coupon_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM orders WHERE id = ?", id, as: Order)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/orders/{id}/cancel" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement cancel behavior
      {result: "ok"}.to_json
    end

    post "/api/orders/{id}/pay" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement pay behavior
      {result: "ok"}.to_json
    end

    post "/api/orders/{id}/process-payment" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement process_payment behavior
      {result: "ok"}.to_json
    end

    get "/api/orders/{id}/total" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement calculate_total behavior
      {result: "ok"}.to_json
    end

    patch "/api/orders/{id}/discount" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement apply_discount behavior
      {result: "ok"}.to_json
    end

    post "/api/orders/{id}/refund" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement refund behavior
      {result: "ok"}.to_json
    end

  end
  def self.order_item_routes
    get "/api/order_items" do |env|
      rows = AppDB.query_all("SELECT * FROM order_items", as: OrderItem)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/order_items/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM order_items WHERE id = ?", id, as: OrderItem)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/order_items" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO order_items (quantity, price_at_purchase, foil, order_id, product_id) VALUES (?, ?, ?, ?, ?)",
        data["quantity"]?.try(&.as_i?) || 0,
        data["price_at_purchase"]?.try(&.as_f?) || 0.0,
        data["foil"]?.try(&.as_bool?) || false,
        data["order_id"]?.try(&.as_i64?),
        data["product_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM order_items WHERE id = ?", id, as: OrderItem)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    delete "/api/order_items/:id" do |env|
      id = env.params.url["id"].to_i64
      AppDB.exec("DELETE FROM order_items WHERE id = ?", id)
      env.response.status_code = 204
    end

    get "/api/order-items/{id}/total" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement line_total behavior
      {result: "ok"}.to_json
    end

  end
  def self.coupon_routes
    get "/api/coupons" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM coupons WHERE code LIKE ?", "%#{q}%", as: Coupon)
      else
        AppDB.query_all("SELECT * FROM coupons", as: Coupon)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/coupons/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM coupons WHERE id = ?", id, as: Coupon)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/coupons" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO coupons (code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["code"]?.try(&.as_s) || "",
        data["discount_type"]?.try(&.as_s) || "Percent",
        data["discount_value"]?.try(&.as_f?) || 0.0,
        data["min_order_value"]?.try(&.as_f?) || 0.0,
        data["max_uses"]?.try(&.as_s?),
        data["uses_count"]?.try(&.as_i?) || 0,
        data["valid_from"]?.try(&.as_s) || "",
        data["valid_until"]?.try(&.as_s) || "",
        data["is_active"]?.try(&.as_bool?) || true
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM coupons WHERE id = ?", id, as: Coupon)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    put "/api/coupons/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "UPDATE coupons SET code = ?, discount_type = ?, discount_value = ?, min_order_value = ?, max_uses = ?, uses_count = ?, valid_from = ?, valid_until = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?",
        data["code"]?.try(&.as_s) || "",
        data["discount_type"]?.try(&.as_s) || "Percent",
        data["discount_value"]?.try(&.as_f?) || 0.0,
        data["min_order_value"]?.try(&.as_f?) || 0.0,
        data["max_uses"]?.try(&.as_i?) || 0,
        data["uses_count"]?.try(&.as_i?) || 0,
        data["valid_from"]?.try(&.as_s) || "",
        data["valid_until"]?.try(&.as_s) || "",
        data["is_active"]?.try(&.as_bool?) || true,
        id
      )
      row = AppDB.query_one?("SELECT * FROM coupons WHERE id = ?", id, as: Coupon)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    patch "/api/coupons/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("code")
        updates << "code = ?"
        values << data["code"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("discount_type")
        updates << "discount_type = ?"
        values << data["discount_type"]?.try(&.as_s) || "Percent"
      end
      if data.as_h.has_key?("discount_value")
        updates << "discount_value = ?"
        values << data["discount_value"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("min_order_value")
        updates << "min_order_value = ?"
        values << data["min_order_value"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("max_uses")
        updates << "max_uses = ?"
        values << data["max_uses"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("uses_count")
        updates << "uses_count = ?"
        values << data["uses_count"]?.try(&.as_i?) || 0
      end
      if data.as_h.has_key?("valid_from")
        updates << "valid_from = ?"
        values << data["valid_from"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("valid_until")
        updates << "valid_until = ?"
        values << data["valid_until"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("is_active")
        updates << "is_active = ?"
        values << data["is_active"]?.try(&.as_bool?) || true
      end
      if updates.empty?
        env.response.status_code = 400
        next {error: "No fields to update"}.to_json
      end
      values << id
      AppDB.exec("UPDATE coupons SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM coupons WHERE id = ?", id, as: Coupon)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    get "/api/coupons/{id}/valid" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_valid behavior
      {result: "ok"}.to_json
    end

    get "/api/coupons/{id}/applicable" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_applicable_to_order behavior
      {result: "ok"}.to_json
    end

    post "/api/coupons/{id}/redeem" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement redeem behavior
      {result: "ok"}.to_json
    end

    post "/api/coupons/{id}/deactivate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement deactivate behavior
      {result: "ok"}.to_json
    end

  end
  def self.trade_listing_routes
    get "/api/trade_listings" do |env|
      q = env.params.query["q"]?
      rows = if q
        AppDB.query_all("SELECT * FROM trade_listings WHERE description LIKE ?", "%#{q}%", as: TradeListing)
      else
        AppDB.query_all("SELECT * FROM trade_listings", as: TradeListing)
      end
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/trade_listings/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM trade_listings WHERE id = ?", id, as: TradeListing)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/trade_listings" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO trade_listings (public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["public_id"]?.try(&.as_s) || "",
        data["status"]?.try(&.as_s) || "Active",
        data["listing_type"]?.try(&.as_s) || "FixedPrice",
        data["asking_price"]?.try(&.as_s?),
        data["auction_start_price"]?.try(&.as_s?),
        data["auction_current_bid"]?.try(&.as_s?),
        data["auctionEndTime"]?.try(&.as_s?),
        data["foil"]?.try(&.as_bool?) || false,
        data["condition"]?.try(&.as_s) || "Mint",
        data["quantity"]?.try(&.as_i?) || 1,
        data["description"]?.try(&.as_s?),
        data["expiresAt"]?.try(&.as_s?),
        data["seller_id"]?.try(&.as_i64?),
        data["card_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM trade_listings WHERE id = ?", id, as: TradeListing)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    patch "/api/trade_listings/:id" do |env|
      id = env.params.url["id"].to_i64
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      updates = [] of String
      values = [] of DB::Any
      if data.as_h.has_key?("public_id")
        updates << "public_id = ?"
        values << data["public_id"]?.try(&.as_s) || ""
      end
      if data.as_h.has_key?("listing_type")
        updates << "listing_type = ?"
        values << data["listing_type"]?.try(&.as_s) || "FixedPrice"
      end
      if data.as_h.has_key?("asking_price")
        updates << "asking_price = ?"
        values << data["asking_price"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("auction_start_price")
        updates << "auction_start_price = ?"
        values << data["auction_start_price"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("auction_current_bid")
        updates << "auction_current_bid = ?"
        values << data["auction_current_bid"]?.try(&.as_f?) || 0.0
      end
      if data.as_h.has_key?("auctionEndTime")
        updates << "auction_end_time = ?"
        values << data["auctionEndTime"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("foil")
        updates << "foil = ?"
        values << data["foil"]?.try(&.as_bool?) || false
      end
      if data.as_h.has_key?("condition")
        updates << "condition = ?"
        values << data["condition"]?.try(&.as_s) || "Mint"
      end
      if data.as_h.has_key?("quantity")
        updates << "quantity = ?"
        values << data["quantity"]?.try(&.as_i?) || 1
      end
      if data.as_h.has_key?("description")
        updates << "description = ?"
        values << data["description"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("expiresAt")
        updates << "expires_at = ?"
        values << data["expiresAt"]?.try(&.as_s?)
      end
      if data.as_h.has_key?("seller_id")
        updates << "seller_id = ?"
        values << data["seller_id"]?.try(&.as_i64?)
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
      AppDB.exec("UPDATE trade_listings SET #{updates.join(", ")}, updated_at = CURRENT_TIMESTAMP WHERE id = ?", args: values)
      row = AppDB.query_one?("SELECT * FROM trade_listings WHERE id = ?", id, as: TradeListing)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/trade-listings/{id}/close" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement close behavior
      {result: "ok"}.to_json
    end

    patch "/api/trade-listings/{id}/extend" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement extend behavior
      {result: "ok"}.to_json
    end

    delete "/api/trade-listings/{id}/cancel" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement cancel behavior
      {result: "ok"}.to_json
    end

    get "/api/trade-listings/{id}/expired" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_expired behavior
      {result: "ok"}.to_json
    end

    post "/api/trade-listings/{id}/finalize" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement finalize_auction behavior
      {result: "ok"}.to_json
    end

  end
  def self.trade_bid_routes
    get "/api/trade_bids" do |env|
      rows = AppDB.query_all("SELECT * FROM trade_bids", as: TradeBid)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/trade_bids/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM trade_bids WHERE id = ?", id, as: TradeBid)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/trade_bids" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO trade_bids (amount, placed_at, is_winning, listing_id, bidder_id) VALUES (?, ?, ?, ?, ?)",
        data["amount"]?.try(&.as_f?) || 0.0,
        data["placedAt"]?.try(&.as_s) || "",
        data["is_winning"]?.try(&.as_bool?) || false,
        data["listing_id"]?.try(&.as_i64?),
        data["bidder_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM trade_bids WHERE id = ?", id, as: TradeBid)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    get "/api/bids/{id}/outbid" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement outbid_by behavior
      {result: "ok"}.to_json
    end

    delete "/api/bids/{id}" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement retract behavior
      {result: "ok"}.to_json
    end

  end
  def self.trade_transaction_routes
    get "/api/trade_transactions" do |env|
      rows = AppDB.query_all("SELECT * FROM trade_transactions", as: TradeTransaction)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/trade_transactions/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM trade_transactions WHERE id = ?", id, as: TradeTransaction)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/transactions/{id}/complete" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement complete behavior
      {result: "ok"}.to_json
    end

    post "/api/transactions/{id}/refund" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement refund behavior
      {result: "ok"}.to_json
    end

    post "/api/transactions/{id}/dispute" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement open_dispute behavior
      {result: "ok"}.to_json
    end

    get "/api/transactions/{id}/seller-net" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement seller_net behavior
      {result: "ok"}.to_json
    end

  end
  def self.card_price_history_routes
    get "/api/card_price_histories" do |env|
      rows = AppDB.query_all("SELECT * FROM card_price_histories", as: CardPriceHistory)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/card_price_histories/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM card_price_histories WHERE id = ?", id, as: CardPriceHistory)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    get "/api/price-history/{id}/change" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement price_change_percent behavior
      {result: "ok"}.to_json
    end

    get "/api/price-history/{id}/spike" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement is_price_spike behavior
      {result: "ok"}.to_json
    end

  end
  def self.trade_dispute_routes
    get "/api/trade_disputes" do |env|
      rows = AppDB.query_all("SELECT * FROM trade_disputes", as: TradeDispute)
      env.response.content_type = "application/json"
      rows.to_json
    end

    get "/api/trade_disputes/:id" do |env|
      id = env.params.url["id"].to_i64
      row = AppDB.query_one?("SELECT * FROM trade_disputes WHERE id = ?", id, as: TradeDispute)
      if row
        env.response.content_type = "application/json"
        row.to_json
      else
        env.response.status_code = 404
        {error: "Not found"}.to_json
      end
    end

    post "/api/trade_disputes" do |env|
      body = env.request.body.try(&.gets_to_end) || "{}"
      data = JSON.parse(body)
      AppDB.exec(
        "INSERT INTO trade_disputes (status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        data["status"]?.try(&.as_s) || "Open",
        data["reason"]?.try(&.as_s) || "",
        data["description"]?.try(&.as_s) || "",
        data["resolution"]?.try(&.as_s?),
        data["openedAt"]?.try(&.as_s) || "",
        data["resolvedAt"]?.try(&.as_s?),
        data["transaction_id"]?.try(&.as_i64?),
        data["opened_by_id"]?.try(&.as_i64?),
        data["resolved_by_id"]?.try(&.as_i64?)
      )
      id = AppDB.last_insert_id
      row = AppDB.query_one("SELECT * FROM trade_disputes WHERE id = ?", id, as: TradeDispute)
      env.response.status_code = 201
      env.response.content_type = "application/json"
      row.to_json
    end

    post "/api/disputes/{id}/escalate" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement escalate behavior
      {result: "ok"}.to_json
    end

    post "/api/disputes/{id}/resolve" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement resolve behavior
      {result: "ok"}.to_json
    end

    post "/api/disputes/{id}/close" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement close_resolved behavior
      {result: "ok"}.to_json
    end

    post "/api/disputes/{id}/review" do |env|
      id = env.params.url["id"]?.try(&.to_i64?)
      env.response.content_type = "application/json"
      # TODO: implement review behavior
      {result: "ok"}.to_json
    end

  end
end
