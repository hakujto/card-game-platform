# CardsProject

## Quick Start

**Requirements:** Java 11+, [Clojure CLI](https://clojure.org/guides/install_clojure)

```bash
bash setup.sh
```

> `setup.sh` creates the SQLite DB, runs Migratus migrations, and starts the http-kit server.

## Manual setup

```bash
mkdir -p db
clojure -M:migrate   # run DB migrations
clojure -M:run       # start server on :3000
```

## API Endpoints

Base URL: `http://localhost:3000`

### Cards BC

- `GET/POST` `/api/cards`
- `GET/PUT/PATCH/DELETE` `/api/cards/:id`
- `GET/POST` `/api/card-sets`
- `GET/PUT/PATCH/DELETE` `/api/card-sets/:id`
- `GET/POST` `/api/card-rulings`
- `GET/PUT/PATCH/DELETE` `/api/card-rulings/:id`
- `GET/POST` `/api/card-abilities`
- `GET/PUT/PATCH/DELETE` `/api/card-abilities/:id`
- `GET/POST` `/api/decks`
- `GET/PUT/PATCH/DELETE` `/api/decks/:id`
- `GET/POST` `/api/deck-cards`
- `GET/PUT/PATCH/DELETE` `/api/deck-cards/:id`
- `GET/POST` `/api/deck-sideboard-cards`
- `GET/PUT/PATCH/DELETE` `/api/deck-sideboard-cards/:id`
- `GET/POST` `/api/deck-tags`
- `GET/PUT/PATCH/DELETE` `/api/deck-tags/:id`
- `GET/POST` `/api/deck-tag-assignments`
- `GET/PUT/PATCH/DELETE` `/api/deck-tag-assignments/:id`

### Players BC

- `GET/POST` `/api/players`
- `GET/PUT/PATCH/DELETE` `/api/players/:id`
- `GET/POST` `/api/player-season-statses`
- `GET/PUT/PATCH/DELETE` `/api/player-season-statses/:id`
- `GET/POST` `/api/player-collections`
- `GET/PUT/PATCH/DELETE` `/api/player-collections/:id`
- `GET/POST` `/api/friendships`
- `GET/PUT/PATCH/DELETE` `/api/friendships/:id`
- `GET/POST` `/api/achievements`
- `GET/PUT/PATCH/DELETE` `/api/achievements/:id`
- `GET/POST` `/api/player-achievements`
- `GET/PUT/PATCH/DELETE` `/api/player-achievements/:id`
- `GET/POST` `/api/crafting-recipes`
- `GET/PUT/PATCH/DELETE` `/api/crafting-recipes/:id`
- `GET/POST` `/api/crafting-ingredients`
- `GET/PUT/PATCH/DELETE` `/api/crafting-ingredients/:id`

### Tournaments BC

- `GET/POST` `/api/seasons`
- `GET/PUT/PATCH/DELETE` `/api/seasons/:id`
- `GET/POST` `/api/tournaments`
- `GET/PUT/PATCH/DELETE` `/api/tournaments/:id`
- `GET/POST` `/api/tournament-judges`
- `GET/PUT/PATCH/DELETE` `/api/tournament-judges/:id`
- `GET/POST` `/api/tournament-registrations`
- `GET/PUT/PATCH/DELETE` `/api/tournament-registrations/:id`
- `GET/POST` `/api/tournament-rounds`
- `GET/PUT/PATCH/DELETE` `/api/tournament-rounds/:id`
- `GET/POST` `/api/matches`
- `GET/PUT/PATCH/DELETE` `/api/matches/:id`
- `GET/POST` `/api/games`
- `GET/PUT/PATCH/DELETE` `/api/games/:id`
- `GET/POST` `/api/tournament-prizes`
- `GET/PUT/PATCH/DELETE` `/api/tournament-prizes/:id`
- `GET/POST` `/api/awarded-prizes`
- `GET/PUT/PATCH/DELETE` `/api/awarded-prizes/:id`

### Marketplace BC

- `GET/POST` `/api/products`
- `GET/PUT/PATCH/DELETE` `/api/products/:id`
- `GET/POST` `/api/orders`
- `GET/PUT/PATCH/DELETE` `/api/orders/:id`
- `GET/POST` `/api/order-items`
- `GET/PUT/PATCH/DELETE` `/api/order-items/:id`
- `GET/POST` `/api/coupons`
- `GET/PUT/PATCH/DELETE` `/api/coupons/:id`
- `GET/POST` `/api/tradelistings`
- `GET/PUT/PATCH/DELETE` `/api/tradelistings/:id`
- `GET/POST` `/api/trade-bids`
- `GET/PUT/PATCH/DELETE` `/api/trade-bids/:id`
- `GET/POST` `/api/trade-transactions`
- `GET/PUT/PATCH/DELETE` `/api/trade-transactions/:id`
- `GET/POST` `/api/card-price-histories`
- `GET/PUT/PATCH/DELETE` `/api/card-price-histories/:id`
- `GET/POST` `/api/trade-disputes`
- `GET/PUT/PATCH/DELETE` `/api/trade-disputes/:id`

### Content BC

- `GET/POST` `/api/draft-sessions`
- `GET/PUT/PATCH/DELETE` `/api/draft-sessions/:id`
- `GET/POST` `/api/draft-participants`
- `GET/PUT/PATCH/DELETE` `/api/draft-participants/:id`
- `GET/POST` `/api/draft-picks`
- `GET/PUT/PATCH/DELETE` `/api/draft-picks/:id`
- `GET/POST` `/api/articles`
- `GET/PUT/PATCH/DELETE` `/api/articles/:id`
- `GET/POST` `/api/article-tags`
- `GET/PUT/PATCH/DELETE` `/api/article-tags/:id`
- `GET/POST` `/api/article-tag-assignments`
- `GET/PUT/PATCH/DELETE` `/api/article-tag-assignments/:id`
- `GET/POST` `/api/article-comments`
- `GET/PUT/PATCH/DELETE` `/api/article-comments/:id`
- `GET/POST` `/api/streams`
- `GET/PUT/PATCH/DELETE` `/api/streams/:id`

## Tests

```bash
clojure -M:test -m cognitect.test-runner
```
