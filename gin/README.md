# cards_project — Gin REST API

## Stack

- Go 1.22+
- Gin 1.10
- GORM 2 with SQLite
- testify

## Quick Start

```bash
cd cards_project
go mod tidy
go run .
```

API: `http://localhost:8080/api/`

## API Endpoints

Base URL: `http://localhost:8080`

### Cards BC

- `GET/POST` `/api/cards`
- `GET/PUT/PATCH/DELETE` `/api/cards/:id`
- `GET/POST` `/api/card_sets`
- `GET/PUT/PATCH/DELETE` `/api/card_sets/:id`
- `GET/POST` `/api/card_rulings`
- `GET/PUT/PATCH/DELETE` `/api/card_rulings/:id`
- `GET/POST` `/api/card_abilities`
- `GET/PUT/PATCH/DELETE` `/api/card_abilities/:id`
- `GET/POST` `/api/decks`
- `GET/PUT/PATCH/DELETE` `/api/decks/:id`
- `GET/POST` `/api/deck_cards`
- `GET/PUT/PATCH/DELETE` `/api/deck_cards/:id`
- `GET/POST` `/api/deck_sideboard_cards`
- `GET/PUT/PATCH/DELETE` `/api/deck_sideboard_cards/:id`
- `GET/POST` `/api/deck_tags`
- `GET/PUT/PATCH/DELETE` `/api/deck_tags/:id`
- `GET/POST` `/api/deck_tag_assignments`
- `GET/PUT/PATCH/DELETE` `/api/deck_tag_assignments/:id`

### Players BC

- `GET/POST` `/api/players`
- `GET/PUT/PATCH/DELETE` `/api/players/:id`
- `GET/POST` `/api/player_season_statses`
- `GET/PUT/PATCH/DELETE` `/api/player_season_statses/:id`
- `GET/POST` `/api/player_collections`
- `GET/PUT/PATCH/DELETE` `/api/player_collections/:id`
- `GET/POST` `/api/friendships`
- `GET/PUT/PATCH/DELETE` `/api/friendships/:id`
- `GET/POST` `/api/achievements`
- `GET/PUT/PATCH/DELETE` `/api/achievements/:id`
- `GET/POST` `/api/player_achievements`
- `GET/PUT/PATCH/DELETE` `/api/player_achievements/:id`
- `GET/POST` `/api/crafting_recipes`
- `GET/PUT/PATCH/DELETE` `/api/crafting_recipes/:id`
- `GET/POST` `/api/crafting_ingredients`
- `GET/PUT/PATCH/DELETE` `/api/crafting_ingredients/:id`

### Tournaments BC

- `GET/POST` `/api/seasons`
- `GET/PUT/PATCH/DELETE` `/api/seasons/:id`
- `GET/POST` `/api/tournaments`
- `GET/PUT/PATCH/DELETE` `/api/tournaments/:id`
- `GET/POST` `/api/tournament_judges`
- `GET/PUT/PATCH/DELETE` `/api/tournament_judges/:id`
- `GET/POST` `/api/tournament_registrations`
- `GET/PUT/PATCH/DELETE` `/api/tournament_registrations/:id`
- `GET/POST` `/api/tournament_rounds`
- `GET/PUT/PATCH/DELETE` `/api/tournament_rounds/:id`
- `GET/POST` `/api/matches`
- `GET/PUT/PATCH/DELETE` `/api/matches/:id`
- `GET/POST` `/api/games`
- `GET/PUT/PATCH/DELETE` `/api/games/:id`
- `GET/POST` `/api/tournament_prizes`
- `GET/PUT/PATCH/DELETE` `/api/tournament_prizes/:id`
- `GET/POST` `/api/awarded_prizes`
- `GET/PUT/PATCH/DELETE` `/api/awarded_prizes/:id`

### Marketplace BC

- `GET/POST` `/api/products`
- `GET/PUT/PATCH/DELETE` `/api/products/:id`
- `GET/POST` `/api/orders`
- `GET/PUT/PATCH/DELETE` `/api/orders/:id`
- `GET/POST` `/api/order_items`
- `GET/PUT/PATCH/DELETE` `/api/order_items/:id`
- `GET/POST` `/api/coupons`
- `GET/PUT/PATCH/DELETE` `/api/coupons/:id`
- `GET/POST` `/api/trade_listings`
- `GET/PUT/PATCH/DELETE` `/api/trade_listings/:id`
- `GET/POST` `/api/trade_bids`
- `GET/PUT/PATCH/DELETE` `/api/trade_bids/:id`
- `GET/POST` `/api/trade_transactions`
- `GET/PUT/PATCH/DELETE` `/api/trade_transactions/:id`
- `GET/POST` `/api/card_price_histories`
- `GET/PUT/PATCH/DELETE` `/api/card_price_histories/:id`
- `GET/POST` `/api/trade_disputes`
- `GET/PUT/PATCH/DELETE` `/api/trade_disputes/:id`

### Content BC

- `GET/POST` `/api/draft_sessions`
- `GET/PUT/PATCH/DELETE` `/api/draft_sessions/:id`
- `GET/POST` `/api/draft_participants`
- `GET/PUT/PATCH/DELETE` `/api/draft_participants/:id`
- `GET/POST` `/api/draft_picks`
- `GET/PUT/PATCH/DELETE` `/api/draft_picks/:id`
- `GET/POST` `/api/articles`
- `GET/PUT/PATCH/DELETE` `/api/articles/:id`
- `GET/POST` `/api/article_tags`
- `GET/PUT/PATCH/DELETE` `/api/article_tags/:id`
- `GET/POST` `/api/article_tag_assignments`
- `GET/PUT/PATCH/DELETE` `/api/article_tag_assignments/:id`
- `GET/POST` `/api/article_comments`
- `GET/PUT/PATCH/DELETE` `/api/article_comments/:id`
- `GET/POST` `/api/streams`
- `GET/PUT/PATCH/DELETE` `/api/streams/:id`

## Tests

```bash
go test ./...
```

## Architecture

Bounded Contexts:

- **Cards BC** (`internal/model/cards/`) — Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment
- **Players BC** (`internal/model/players/`) — Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient
- **Tournaments BC** (`internal/model/tournaments/`) — Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize
- **Marketplace BC** (`internal/model/marketplace/`) — Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
- **Content BC** (`internal/model/content/`) — DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream

## Docker

```bash
docker build -t app .
docker run -p 8080:8080 app
```
