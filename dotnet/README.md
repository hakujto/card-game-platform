# CardsProject — ASP.NET Core REST API

## Stack

- ASP.NET Core 10 + EF Core 10 (SQLite)
- ASP.NET Core Identity (auth)
- Swagger UI (Swashbuckle)

## Quickstart

```bash
cd cards_project
dotnet restore
dotnet ef database update
dotnet run
```

API:     http://localhost:5000/api/
Swagger: http://localhost:5000/swagger

## Endpoints

```
GET    /api/cards      — list all
POST   /api/cards      — create
GET    /api/cards/{id} — get by id
PUT    /api/cards/{id} — update
DELETE /api/cards/{id} — delete
GET    /api/card_sets      — list all
POST   /api/card_sets      — create
GET    /api/card_sets/{id} — get by id
PUT    /api/card_sets/{id} — update
DELETE /api/card_sets/{id} — delete
GET    /api/card_rulings      — list all
POST   /api/card_rulings      — create
GET    /api/card_rulings/{id} — get by id
PUT    /api/card_rulings/{id} — update
DELETE /api/card_rulings/{id} — delete
GET    /api/card_abilities      — list all
POST   /api/card_abilities      — create
GET    /api/card_abilities/{id} — get by id
PUT    /api/card_abilities/{id} — update
DELETE /api/card_abilities/{id} — delete
GET    /api/decks      — list all
POST   /api/decks      — create
GET    /api/decks/{id} — get by id
PUT    /api/decks/{id} — update
DELETE /api/decks/{id} — delete
GET    /api/deck_cards      — list all
POST   /api/deck_cards      — create
GET    /api/deck_cards/{id} — get by id
PUT    /api/deck_cards/{id} — update
DELETE /api/deck_cards/{id} — delete
GET    /api/deck_sideboard_cards      — list all
POST   /api/deck_sideboard_cards      — create
GET    /api/deck_sideboard_cards/{id} — get by id
PUT    /api/deck_sideboard_cards/{id} — update
DELETE /api/deck_sideboard_cards/{id} — delete
GET    /api/deck_tags      — list all
POST   /api/deck_tags      — create
GET    /api/deck_tags/{id} — get by id
PUT    /api/deck_tags/{id} — update
DELETE /api/deck_tags/{id} — delete
GET    /api/deck_tag_assignments      — list all
POST   /api/deck_tag_assignments      — create
GET    /api/deck_tag_assignments/{id} — get by id
PUT    /api/deck_tag_assignments/{id} — update
DELETE /api/deck_tag_assignments/{id} — delete
GET    /api/players      — list all
POST   /api/players      — create
GET    /api/players/{id} — get by id
PUT    /api/players/{id} — update
DELETE /api/players/{id} — delete
GET    /api/player_season_statses      — list all
POST   /api/player_season_statses      — create
GET    /api/player_season_statses/{id} — get by id
PUT    /api/player_season_statses/{id} — update
DELETE /api/player_season_statses/{id} — delete
GET    /api/player_collections      — list all
POST   /api/player_collections      — create
GET    /api/player_collections/{id} — get by id
PUT    /api/player_collections/{id} — update
DELETE /api/player_collections/{id} — delete
GET    /api/friendships      — list all
POST   /api/friendships      — create
GET    /api/friendships/{id} — get by id
PUT    /api/friendships/{id} — update
DELETE /api/friendships/{id} — delete
GET    /api/achievements      — list all
POST   /api/achievements      — create
GET    /api/achievements/{id} — get by id
PUT    /api/achievements/{id} — update
DELETE /api/achievements/{id} — delete
GET    /api/player_achievements      — list all
POST   /api/player_achievements      — create
GET    /api/player_achievements/{id} — get by id
PUT    /api/player_achievements/{id} — update
DELETE /api/player_achievements/{id} — delete
GET    /api/crafting_recipes      — list all
POST   /api/crafting_recipes      — create
GET    /api/crafting_recipes/{id} — get by id
PUT    /api/crafting_recipes/{id} — update
DELETE /api/crafting_recipes/{id} — delete
GET    /api/crafting_ingredients      — list all
POST   /api/crafting_ingredients      — create
GET    /api/crafting_ingredients/{id} — get by id
PUT    /api/crafting_ingredients/{id} — update
DELETE /api/crafting_ingredients/{id} — delete
GET    /api/seasons      — list all
POST   /api/seasons      — create
GET    /api/seasons/{id} — get by id
PUT    /api/seasons/{id} — update
DELETE /api/seasons/{id} — delete
GET    /api/tournaments      — list all
POST   /api/tournaments      — create
GET    /api/tournaments/{id} — get by id
PUT    /api/tournaments/{id} — update
DELETE /api/tournaments/{id} — delete
GET    /api/tournament_judges      — list all
POST   /api/tournament_judges      — create
GET    /api/tournament_judges/{id} — get by id
PUT    /api/tournament_judges/{id} — update
DELETE /api/tournament_judges/{id} — delete
GET    /api/tournament_registrations      — list all
POST   /api/tournament_registrations      — create
GET    /api/tournament_registrations/{id} — get by id
PUT    /api/tournament_registrations/{id} — update
DELETE /api/tournament_registrations/{id} — delete
GET    /api/tournament_rounds      — list all
POST   /api/tournament_rounds      — create
GET    /api/tournament_rounds/{id} — get by id
PUT    /api/tournament_rounds/{id} — update
DELETE /api/tournament_rounds/{id} — delete
GET    /api/matches      — list all
POST   /api/matches      — create
GET    /api/matches/{id} — get by id
PUT    /api/matches/{id} — update
DELETE /api/matches/{id} — delete
GET    /api/games      — list all
POST   /api/games      — create
GET    /api/games/{id} — get by id
PUT    /api/games/{id} — update
DELETE /api/games/{id} — delete
GET    /api/tournament_prizes      — list all
POST   /api/tournament_prizes      — create
GET    /api/tournament_prizes/{id} — get by id
PUT    /api/tournament_prizes/{id} — update
DELETE /api/tournament_prizes/{id} — delete
GET    /api/awarded_prizes      — list all
POST   /api/awarded_prizes      — create
GET    /api/awarded_prizes/{id} — get by id
PUT    /api/awarded_prizes/{id} — update
DELETE /api/awarded_prizes/{id} — delete
GET    /api/products      — list all
POST   /api/products      — create
GET    /api/products/{id} — get by id
PUT    /api/products/{id} — update
DELETE /api/products/{id} — delete
GET    /api/orders      — list all
POST   /api/orders      — create
GET    /api/orders/{id} — get by id
PUT    /api/orders/{id} — update
DELETE /api/orders/{id} — delete
GET    /api/order_items      — list all
POST   /api/order_items      — create
GET    /api/order_items/{id} — get by id
PUT    /api/order_items/{id} — update
DELETE /api/order_items/{id} — delete
GET    /api/coupons      — list all
POST   /api/coupons      — create
GET    /api/coupons/{id} — get by id
PUT    /api/coupons/{id} — update
DELETE /api/coupons/{id} — delete
GET    /api/tradelistings      — list all
POST   /api/tradelistings      — create
GET    /api/tradelistings/{id} — get by id
PUT    /api/tradelistings/{id} — update
DELETE /api/tradelistings/{id} — delete
GET    /api/trade_bids      — list all
POST   /api/trade_bids      — create
GET    /api/trade_bids/{id} — get by id
PUT    /api/trade_bids/{id} — update
DELETE /api/trade_bids/{id} — delete
GET    /api/trade_transactions      — list all
POST   /api/trade_transactions      — create
GET    /api/trade_transactions/{id} — get by id
PUT    /api/trade_transactions/{id} — update
DELETE /api/trade_transactions/{id} — delete
GET    /api/card_price_histories      — list all
POST   /api/card_price_histories      — create
GET    /api/card_price_histories/{id} — get by id
PUT    /api/card_price_histories/{id} — update
DELETE /api/card_price_histories/{id} — delete
GET    /api/trade_disputes      — list all
POST   /api/trade_disputes      — create
GET    /api/trade_disputes/{id} — get by id
PUT    /api/trade_disputes/{id} — update
DELETE /api/trade_disputes/{id} — delete
GET    /api/draft_sessions      — list all
POST   /api/draft_sessions      — create
GET    /api/draft_sessions/{id} — get by id
PUT    /api/draft_sessions/{id} — update
DELETE /api/draft_sessions/{id} — delete
GET    /api/draft_participants      — list all
POST   /api/draft_participants      — create
GET    /api/draft_participants/{id} — get by id
PUT    /api/draft_participants/{id} — update
DELETE /api/draft_participants/{id} — delete
GET    /api/draft_picks      — list all
POST   /api/draft_picks      — create
GET    /api/draft_picks/{id} — get by id
PUT    /api/draft_picks/{id} — update
DELETE /api/draft_picks/{id} — delete
GET    /api/articles      — list all
POST   /api/articles      — create
GET    /api/articles/{id} — get by id
PUT    /api/articles/{id} — update
DELETE /api/articles/{id} — delete
GET    /api/article_tags      — list all
POST   /api/article_tags      — create
GET    /api/article_tags/{id} — get by id
PUT    /api/article_tags/{id} — update
DELETE /api/article_tags/{id} — delete
GET    /api/article_tag_assignments      — list all
POST   /api/article_tag_assignments      — create
GET    /api/article_tag_assignments/{id} — get by id
PUT    /api/article_tag_assignments/{id} — update
DELETE /api/article_tag_assignments/{id} — delete
GET    /api/article_comments      — list all
POST   /api/article_comments      — create
GET    /api/article_comments/{id} — get by id
PUT    /api/article_comments/{id} — update
DELETE /api/article_comments/{id} — delete
GET    /api/streams      — list all
POST   /api/streams      — create
GET    /api/streams/{id} — get by id
PUT    /api/streams/{id} — update
DELETE /api/streams/{id} — delete
```

## Tests

```bash
dotnet test
```
