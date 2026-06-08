# CardsProject

## Quick Start

**Requirements:** OCaml 5.0+, opam, dune

```bash
bash setup.sh
```

> `setup.sh` installs opam deps, builds, runs migrations, and starts Dream server.

## Manual setup

```bash
opam install . --deps-only  # install deps
dune build                  # compile
./_build/default/migrate.exe   # create SQLite tables
./_build/default/main.exe      # start server on :3000
```

## API Endpoints

Base URL: `http://localhost:3000`

### Cards BC

- `GET/POST` `/api/cards`
- `GET/PUT/DELETE` `/api/cards/:id`
- `GET/POST` `/api/card_sets`
- `GET/PUT/DELETE` `/api/card_sets/:id`
- `GET/POST` `/api/card_rulings`
- `GET/PUT/DELETE` `/api/card_rulings/:id`
- `GET/POST` `/api/card_abilities`
- `GET/PUT/DELETE` `/api/card_abilities/:id`
- `GET/POST` `/api/decks`
- `GET/PUT/DELETE` `/api/decks/:id`
- `GET/POST` `/api/deck_cards`
- `GET/PUT/DELETE` `/api/deck_cards/:id`
- `GET/POST` `/api/deck_sideboard_cards`
- `GET/PUT/DELETE` `/api/deck_sideboard_cards/:id`
- `GET/POST` `/api/deck_tags`
- `GET/PUT/DELETE` `/api/deck_tags/:id`
- `GET/POST` `/api/deck_tag_assignments`
- `GET/PUT/DELETE` `/api/deck_tag_assignments/:id`

### Players BC

- `GET/POST` `/api/players`
- `GET/PUT/DELETE` `/api/players/:id`
- `GET/POST` `/api/player_season_statses`
- `GET/PUT/DELETE` `/api/player_season_statses/:id`
- `GET/POST` `/api/player_collections`
- `GET/PUT/DELETE` `/api/player_collections/:id`
- `GET/POST` `/api/friendships`
- `GET/PUT/DELETE` `/api/friendships/:id`
- `GET/POST` `/api/achievements`
- `GET/PUT/DELETE` `/api/achievements/:id`
- `GET/POST` `/api/player_achievements`
- `GET/PUT/DELETE` `/api/player_achievements/:id`
- `GET/POST` `/api/crafting_recipes`
- `GET/PUT/DELETE` `/api/crafting_recipes/:id`
- `GET/POST` `/api/crafting_ingredients`
- `GET/PUT/DELETE` `/api/crafting_ingredients/:id`

### Tournaments BC

- `GET/POST` `/api/seasons`
- `GET/PUT/DELETE` `/api/seasons/:id`
- `GET/POST` `/api/tournaments`
- `GET/PUT/DELETE` `/api/tournaments/:id`
- `GET/POST` `/api/tournament_judges`
- `GET/PUT/DELETE` `/api/tournament_judges/:id`
- `GET/POST` `/api/tournament_registrations`
- `GET/PUT/DELETE` `/api/tournament_registrations/:id`
- `GET/POST` `/api/tournament_rounds`
- `GET/PUT/DELETE` `/api/tournament_rounds/:id`
- `GET/POST` `/api/matches`
- `GET/PUT/DELETE` `/api/matches/:id`
- `GET/POST` `/api/games`
- `GET/PUT/DELETE` `/api/games/:id`
- `GET/POST` `/api/tournament_prizes`
- `GET/PUT/DELETE` `/api/tournament_prizes/:id`
- `GET/POST` `/api/awarded_prizes`
- `GET/PUT/DELETE` `/api/awarded_prizes/:id`

### Marketplace BC

- `GET/POST` `/api/products`
- `GET/PUT/DELETE` `/api/products/:id`
- `GET/POST` `/api/orders`
- `GET/PUT/DELETE` `/api/orders/:id`
- `GET/POST` `/api/order_items`
- `GET/PUT/DELETE` `/api/order_items/:id`
- `GET/POST` `/api/coupons`
- `GET/PUT/DELETE` `/api/coupons/:id`
- `GET/POST` `/api/trade_listings`
- `GET/PUT/DELETE` `/api/trade_listings/:id`
- `GET/POST` `/api/trade_bids`
- `GET/PUT/DELETE` `/api/trade_bids/:id`
- `GET/POST` `/api/trade_transactions`
- `GET/PUT/DELETE` `/api/trade_transactions/:id`
- `GET/POST` `/api/card_price_histories`
- `GET/PUT/DELETE` `/api/card_price_histories/:id`
- `GET/POST` `/api/trade_disputes`
- `GET/PUT/DELETE` `/api/trade_disputes/:id`

### Content BC

- `GET/POST` `/api/draft_sessions`
- `GET/PUT/DELETE` `/api/draft_sessions/:id`
- `GET/POST` `/api/draft_participants`
- `GET/PUT/DELETE` `/api/draft_participants/:id`
- `GET/POST` `/api/draft_picks`
- `GET/PUT/DELETE` `/api/draft_picks/:id`
- `GET/POST` `/api/articles`
- `GET/PUT/DELETE` `/api/articles/:id`
- `GET/POST` `/api/article_tags`
- `GET/PUT/DELETE` `/api/article_tags/:id`
- `GET/POST` `/api/article_tag_assignments`
- `GET/PUT/DELETE` `/api/article_tag_assignments/:id`
- `GET/POST` `/api/article_comments`
- `GET/PUT/DELETE` `/api/article_comments/:id`
- `GET/POST` `/api/streams`
- `GET/PUT/DELETE` `/api/streams/:id`

## Tests

```bash
# --force makes dune print test output even when all tests pass
dune test --force
```

## Architecture

Stack: **OCaml 5 + Dream + Caqti + SQLite + ppx_deriving_yojson + Alcotest**

Bounded Contexts:

- **Cards BC** (`lib/cards_project/cards/`) — Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment
- **Players BC** (`lib/cards_project/players/`) — Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient
- **Tournaments BC** (`lib/cards_project/tournaments/`) — Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize
- **Marketplace BC** (`lib/cards_project/marketplace/`) — Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
- **Content BC** (`lib/cards_project/content/`) — DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream
