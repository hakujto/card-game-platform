# CardsProject

## Stack

- Laravel 11 + Eloquent ORM (SQLite)
- Laravel Sanctum (API auth)
- PHPUnit

## Quick Start

```bash
bash setup.sh
php artisan serve
```

> `setup.sh` runs `composer install`, copies `.env.example` → `.env`, generates app key, creates the SQLite DB, and runs migrations.

API: http://localhost:8000/api/

## API Endpoints

### Cards BC
- `GET` `/api/cards` — list
- `POST` `/api/cards` — create
- `GET` `/api/cards/{id}` — show
- `PUT/PATCH` `/api/cards/{id}` — update
- `DELETE` `/api/cards/{id}` — delete
- `GET` `/api/card_sets` — list
- `POST` `/api/card_sets` — create
- `GET` `/api/card_sets/{id}` — show
- `PUT/PATCH` `/api/card_sets/{id}` — update
- `DELETE` `/api/card_sets/{id}` — delete
- `GET` `/api/card_rulings` — list
- `POST` `/api/card_rulings` — create
- `GET` `/api/card_rulings/{id}` — show
- `PUT/PATCH` `/api/card_rulings/{id}` — update
- `DELETE` `/api/card_rulings/{id}` — delete
- `GET` `/api/card_abilities` — list
- `POST` `/api/card_abilities` — create
- `GET` `/api/card_abilities/{id}` — show
- `PUT/PATCH` `/api/card_abilities/{id}` — update
- `DELETE` `/api/card_abilities/{id}` — delete
- `GET` `/api/decks` — list
- `POST` `/api/decks` — create
- `GET` `/api/decks/{id}` — show
- `PUT/PATCH` `/api/decks/{id}` — update
- `DELETE` `/api/decks/{id}` — delete
- `GET` `/api/deck_cards` — list
- `POST` `/api/deck_cards` — create
- `GET` `/api/deck_cards/{id}` — show
- `PUT/PATCH` `/api/deck_cards/{id}` — update
- `DELETE` `/api/deck_cards/{id}` — delete
- `GET` `/api/deck_sideboard_cards` — list
- `POST` `/api/deck_sideboard_cards` — create
- `GET` `/api/deck_sideboard_cards/{id}` — show
- `PUT/PATCH` `/api/deck_sideboard_cards/{id}` — update
- `DELETE` `/api/deck_sideboard_cards/{id}` — delete
- `GET` `/api/deck_tags` — list
- `POST` `/api/deck_tags` — create
- `GET` `/api/deck_tags/{id}` — show
- `PUT/PATCH` `/api/deck_tags/{id}` — update
- `DELETE` `/api/deck_tags/{id}` — delete
- `GET` `/api/deck_tag_assignments` — list
- `POST` `/api/deck_tag_assignments` — create
- `GET` `/api/deck_tag_assignments/{id}` — show
- `PUT/PATCH` `/api/deck_tag_assignments/{id}` — update
- `DELETE` `/api/deck_tag_assignments/{id}` — delete

### Players BC
- `GET` `/api/players` — list
- `POST` `/api/players` — create
- `GET` `/api/players/{id}` — show
- `PUT/PATCH` `/api/players/{id}` — update
- `DELETE` `/api/players/{id}` — delete
- `GET` `/api/player_season_statses` — list
- `POST` `/api/player_season_statses` — create
- `GET` `/api/player_season_statses/{id}` — show
- `PUT/PATCH` `/api/player_season_statses/{id}` — update
- `DELETE` `/api/player_season_statses/{id}` — delete
- `GET` `/api/player_collections` — list
- `POST` `/api/player_collections` — create
- `GET` `/api/player_collections/{id}` — show
- `PUT/PATCH` `/api/player_collections/{id}` — update
- `DELETE` `/api/player_collections/{id}` — delete
- `GET` `/api/friendships` — list
- `POST` `/api/friendships` — create
- `GET` `/api/friendships/{id}` — show
- `PUT/PATCH` `/api/friendships/{id}` — update
- `DELETE` `/api/friendships/{id}` — delete
- `GET` `/api/achievements` — list
- `POST` `/api/achievements` — create
- `GET` `/api/achievements/{id}` — show
- `PUT/PATCH` `/api/achievements/{id}` — update
- `DELETE` `/api/achievements/{id}` — delete
- `GET` `/api/player_achievements` — list
- `POST` `/api/player_achievements` — create
- `GET` `/api/player_achievements/{id}` — show
- `PUT/PATCH` `/api/player_achievements/{id}` — update
- `DELETE` `/api/player_achievements/{id}` — delete
- `GET` `/api/crafting_recipes` — list
- `POST` `/api/crafting_recipes` — create
- `GET` `/api/crafting_recipes/{id}` — show
- `PUT/PATCH` `/api/crafting_recipes/{id}` — update
- `DELETE` `/api/crafting_recipes/{id}` — delete
- `GET` `/api/crafting_ingredients` — list
- `POST` `/api/crafting_ingredients` — create
- `GET` `/api/crafting_ingredients/{id}` — show
- `PUT/PATCH` `/api/crafting_ingredients/{id}` — update
- `DELETE` `/api/crafting_ingredients/{id}` — delete

### Tournaments BC
- `GET` `/api/seasons` — list
- `POST` `/api/seasons` — create
- `GET` `/api/seasons/{id}` — show
- `PUT/PATCH` `/api/seasons/{id}` — update
- `DELETE` `/api/seasons/{id}` — delete
- `GET` `/api/tournaments` — list
- `POST` `/api/tournaments` — create
- `GET` `/api/tournaments/{id}` — show
- `PUT/PATCH` `/api/tournaments/{id}` — update
- `DELETE` `/api/tournaments/{id}` — delete
- `GET` `/api/tournament_judges` — list
- `POST` `/api/tournament_judges` — create
- `GET` `/api/tournament_judges/{id}` — show
- `PUT/PATCH` `/api/tournament_judges/{id}` — update
- `DELETE` `/api/tournament_judges/{id}` — delete
- `GET` `/api/tournament_registrations` — list
- `POST` `/api/tournament_registrations` — create
- `GET` `/api/tournament_registrations/{id}` — show
- `PUT/PATCH` `/api/tournament_registrations/{id}` — update
- `DELETE` `/api/tournament_registrations/{id}` — delete
- `GET` `/api/tournament_rounds` — list
- `POST` `/api/tournament_rounds` — create
- `GET` `/api/tournament_rounds/{id}` — show
- `PUT/PATCH` `/api/tournament_rounds/{id}` — update
- `DELETE` `/api/tournament_rounds/{id}` — delete
- `GET` `/api/matches` — list
- `POST` `/api/matches` — create
- `GET` `/api/matches/{id}` — show
- `PUT/PATCH` `/api/matches/{id}` — update
- `DELETE` `/api/matches/{id}` — delete
- `GET` `/api/games` — list
- `POST` `/api/games` — create
- `GET` `/api/games/{id}` — show
- `PUT/PATCH` `/api/games/{id}` — update
- `DELETE` `/api/games/{id}` — delete
- `GET` `/api/tournament_prizes` — list
- `POST` `/api/tournament_prizes` — create
- `GET` `/api/tournament_prizes/{id}` — show
- `PUT/PATCH` `/api/tournament_prizes/{id}` — update
- `DELETE` `/api/tournament_prizes/{id}` — delete
- `GET` `/api/awarded_prizes` — list
- `POST` `/api/awarded_prizes` — create
- `GET` `/api/awarded_prizes/{id}` — show
- `PUT/PATCH` `/api/awarded_prizes/{id}` — update
- `DELETE` `/api/awarded_prizes/{id}` — delete

### Marketplace BC
- `GET` `/api/products` — list
- `POST` `/api/products` — create
- `GET` `/api/products/{id}` — show
- `PUT/PATCH` `/api/products/{id}` — update
- `DELETE` `/api/products/{id}` — delete
- `GET` `/api/orders` — list
- `POST` `/api/orders` — create
- `GET` `/api/orders/{id}` — show
- `PUT/PATCH` `/api/orders/{id}` — update
- `DELETE` `/api/orders/{id}` — delete
- `GET` `/api/order_items` — list
- `POST` `/api/order_items` — create
- `GET` `/api/order_items/{id}` — show
- `PUT/PATCH` `/api/order_items/{id}` — update
- `DELETE` `/api/order_items/{id}` — delete
- `GET` `/api/coupons` — list
- `POST` `/api/coupons` — create
- `GET` `/api/coupons/{id}` — show
- `PUT/PATCH` `/api/coupons/{id}` — update
- `DELETE` `/api/coupons/{id}` — delete
- `GET` `/api/trade_listings` — list
- `POST` `/api/trade_listings` — create
- `GET` `/api/trade_listings/{id}` — show
- `PUT/PATCH` `/api/trade_listings/{id}` — update
- `DELETE` `/api/trade_listings/{id}` — delete
- `GET` `/api/trade_bids` — list
- `POST` `/api/trade_bids` — create
- `GET` `/api/trade_bids/{id}` — show
- `PUT/PATCH` `/api/trade_bids/{id}` — update
- `DELETE` `/api/trade_bids/{id}` — delete
- `GET` `/api/trade_transactions` — list
- `POST` `/api/trade_transactions` — create
- `GET` `/api/trade_transactions/{id}` — show
- `PUT/PATCH` `/api/trade_transactions/{id}` — update
- `DELETE` `/api/trade_transactions/{id}` — delete
- `GET` `/api/card_price_histories` — list
- `POST` `/api/card_price_histories` — create
- `GET` `/api/card_price_histories/{id}` — show
- `PUT/PATCH` `/api/card_price_histories/{id}` — update
- `DELETE` `/api/card_price_histories/{id}` — delete
- `GET` `/api/trade_disputes` — list
- `POST` `/api/trade_disputes` — create
- `GET` `/api/trade_disputes/{id}` — show
- `PUT/PATCH` `/api/trade_disputes/{id}` — update
- `DELETE` `/api/trade_disputes/{id}` — delete

### Content BC
- `GET` `/api/draft_sessions` — list
- `POST` `/api/draft_sessions` — create
- `GET` `/api/draft_sessions/{id}` — show
- `PUT/PATCH` `/api/draft_sessions/{id}` — update
- `DELETE` `/api/draft_sessions/{id}` — delete
- `GET` `/api/draft_participants` — list
- `POST` `/api/draft_participants` — create
- `GET` `/api/draft_participants/{id}` — show
- `PUT/PATCH` `/api/draft_participants/{id}` — update
- `DELETE` `/api/draft_participants/{id}` — delete
- `GET` `/api/draft_picks` — list
- `POST` `/api/draft_picks` — create
- `GET` `/api/draft_picks/{id}` — show
- `PUT/PATCH` `/api/draft_picks/{id}` — update
- `DELETE` `/api/draft_picks/{id}` — delete
- `GET` `/api/articles` — list
- `POST` `/api/articles` — create
- `GET` `/api/articles/{id}` — show
- `PUT/PATCH` `/api/articles/{id}` — update
- `DELETE` `/api/articles/{id}` — delete
- `GET` `/api/article_tags` — list
- `POST` `/api/article_tags` — create
- `GET` `/api/article_tags/{id}` — show
- `PUT/PATCH` `/api/article_tags/{id}` — update
- `DELETE` `/api/article_tags/{id}` — delete
- `GET` `/api/article_tag_assignments` — list
- `POST` `/api/article_tag_assignments` — create
- `GET` `/api/article_tag_assignments/{id}` — show
- `PUT/PATCH` `/api/article_tag_assignments/{id}` — update
- `DELETE` `/api/article_tag_assignments/{id}` — delete
- `GET` `/api/article_comments` — list
- `POST` `/api/article_comments` — create
- `GET` `/api/article_comments/{id}` — show
- `PUT/PATCH` `/api/article_comments/{id}` — update
- `DELETE` `/api/article_comments/{id}` — delete
- `GET` `/api/streams` — list
- `POST` `/api/streams` — create
- `GET` `/api/streams/{id}` — show
- `PUT/PATCH` `/api/streams/{id}` — update
- `DELETE` `/api/streams/{id}` — delete

## Tests

```bash
php artisan test
```

## Docker

```bash
docker build -t app .
docker run -p 8000:8000 app
```

## CI

GitHub Actions workflow in `.github/workflows/ci.yml` — runs on push and pull_request:
sets up PHP 8.3 with pdo_sqlite, installs Composer dependencies, runs migrations, and executes PHPUnit.
