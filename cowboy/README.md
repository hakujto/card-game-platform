# cards_project — Cowboy REST API

## Stack

- Erlang/OTP 27 + Cowboy 2.x
- Mnesia (in-memory store)
- EUnit

## Quick Start

```bash
./setup.sh
rebar3 shell
```

API available at `http://localhost:8080/api/`

## Tests

```bash
# Run EUnit test suite
rebar3 eunit

# Smoke-test all POSTs (requires running server)
./test_post.sh
```

## API Endpoints

### Cards BC
- `GET/POST` `/api/cards/`
- `GET/PUT/PATCH` `/api/cards/{id}/`
- `POST` `/api/cards/{id}/ban`
- `POST` `/api/cards/{id}/unban`
- `POST` `/api/cards/{id}/restrict`
- `POST` `/api/cards/{id}/unrestrict`
- `GET` `/api/cards/{id}/value`
- `POST` `/api/cards/{id}/rarity-bonus`
- `GET` `/api/cards/{id}/legal`
- `GET/POST` `/api/card_sets/`
- `GET/PUT/PATCH` `/api/card_sets/{id}/`
- `GET` `/api/card-sets/{id}/standard-legal`
- `GET` `/api/card-sets/{id}/legal`
- `GET` `/api/card-sets/{id}/rarity-count`
- `POST` `/api/card-sets/{id}/rotate`
- `GET/POST` `/api/card_rulings/`
- `GET/DELETE` `/api/card_rulings/{id}/`
- `GET` `/api/card-rulings/{id}/current`
- `GET` `/api/card-rulings/{id}/supersedes`
- `GET/POST` `/api/card_abilities/`
- `GET/PUT/PATCH/DELETE` `/api/card_abilities/{id}/`
- `GET` `/api/card-abilities/{id}/usable`
- `GET` `/api/card-abilities/{id}/describe`
- `GET/POST` `/api/decks/`
- `GET/PUT/PATCH/DELETE` `/api/decks/{id}/`
- `GET` `/api/decks/{id}/validate`
- `POST` `/api/decks/{id}/cards`
- `DELETE` `/api/decks/{id}/cards/{card_id}`
- `GET` `/api/decks/{id}/win-rate`
- `POST` `/api/decks/{id}/clone`
- `POST` `/api/decks/{id}/publish`
- `POST` `/api/decks/{id}/unpublish`
- `POST` `/api/decks/{id}/certify`
- `GET/POST` `/api/deck_cards/`
- `GET/PATCH/DELETE` `/api/deck_cards/{id}/`
- `PATCH` `/api/deck-cards/{id}/increment`
- `PATCH` `/api/deck-cards/{id}/decrement`
- `GET/POST` `/api/deck_sideboard_cards/`
- `GET/PATCH/DELETE` `/api/deck_sideboard_cards/{id}/`
- `PATCH` `/api/sideboard-cards/{id}/increment`
- `PATCH` `/api/sideboard-cards/{id}/decrement`
- `GET/POST` `/api/deck_tags/`
- `GET/PATCH/DELETE` `/api/deck_tags/{id}/`
- `PATCH` `/api/deck-tags/{id}/rename`
- `POST` `/api/deck-tags/{id}/merge`
- `GET/POST` `/api/deck_tag_assignments/`
- `GET/DELETE` `/api/deck_tag_assignments/{id}/`

### Players BC
- `GET/POST` `/api/players/`
- `GET/PATCH` `/api/players/{id}/`
- `POST` `/api/players/{id}/promote`
- `POST` `/api/players/{id}/demote`
- `POST` `/api/players/{id}/win`
- `POST` `/api/players/{id}/loss`
- `GET` `/api/players/{id}/win-rate`
- `POST` `/api/players/{id}/verify`
- `PATCH` `/api/players/{id}/rating`
- `GET` `/api/player_season_statses/`
- `GET` `/api/player_season_statses/{id}/`
- `GET` `/api/player-season-stats/{id}/win-rate`
- `PATCH` `/api/player-season-stats/{id}/points`
- `POST` `/api/player-season-stats/{id}/tournament-win`
- `GET/POST` `/api/player_collections/`
- `GET/PATCH/DELETE` `/api/player_collections/{id}/`
- `POST` `/api/collection/{id}/add`
- `POST` `/api/collection/{id}/remove`
- `GET` `/api/collection/{id}/value`
- `GET/POST` `/api/friendships/`
- `GET/DELETE` `/api/friendships/{id}/`
- `POST` `/api/friendships/{id}/accept`
- `POST` `/api/friendships/{id}/decline`
- `POST` `/api/friendships/{id}/block`
- `GET/POST` `/api/achievements/`
- `GET/PUT/PATCH` `/api/achievements/{id}/`
- `GET` `/api/achievements/{id}/point-value`
- `POST` `/api/achievements/{id}/reveal`
- `GET` `/api/player_achievements/`
- `GET` `/api/player_achievements/{id}/`
- `PATCH` `/api/player-achievements/{id}/progress`
- `POST` `/api/player-achievements/{id}/complete`
- `GET/POST` `/api/crafting_recipes/`
- `GET/PUT/PATCH` `/api/crafting_recipes/{id}/`
- `GET` `/api/crafting-recipes/{id}/can-craft`
- `POST` `/api/crafting-recipes/{id}/craft`
- `POST` `/api/crafting-recipes/{id}/disable`
- `POST` `/api/crafting-recipes/{id}/enable`
- `GET/POST` `/api/crafting_ingredients/`
- `GET/DELETE` `/api/crafting_ingredients/{id}/`

### Tournaments BC
- `GET/POST` `/api/seasons/`
- `GET/PUT/PATCH` `/api/seasons/{id}/`
- `POST` `/api/seasons/{id}/activate`
- `POST` `/api/seasons/{id}/deactivate`
- `POST` `/api/seasons/{id}/finalize`
- `GET` `/api/seasons/{id}/ongoing`
- `GET/POST` `/api/tournaments/`
- `GET/PUT/PATCH` `/api/tournaments/{id}/`
- `POST` `/api/tournaments/{id}/transition/draft-to-registration`
- `POST` `/api/tournaments/{id}/transition/registration-to-ongoing`
- `POST` `/api/tournaments/{id}/transition/registration-to-cancelled`
- `POST` `/api/tournaments/{id}/transition/ongoing-to-completed`
- `POST` `/api/tournaments/{id}/transition/ongoing-to-cancelled`
- `POST` `/api/tournaments/{id}/start`
- `POST` `/api/tournaments/{id}/cancel`
- `POST` `/api/tournaments/{id}/complete`
- `POST` `/api/tournaments/{id}/rounds`
- `GET` `/api/tournaments/{id}/prizes`
- `POST` `/api/tournaments/{id}/register`
- `GET` `/api/tournaments/{id}/full`
- `GET/POST` `/api/tournament_judges/`
- `GET/DELETE` `/api/tournament_judges/{id}/`
- `POST` `/api/tournament-judges/{id}/promote`
- `DELETE` `/api/tournament-judges/{id}`
- `GET/POST` `/api/tournament_registrations/`
- `GET` `/api/tournament_registrations/{id}/`
- `POST` `/api/registrations/{id}/withdraw`
- `POST` `/api/registrations/{id}/disqualify`
- `POST` `/api/registrations/{id}/promote`
- `GET/POST` `/api/tournament_rounds/`
- `GET` `/api/tournament_rounds/{id}/`
- `POST` `/api/rounds/{id}/start`
- `POST` `/api/rounds/{id}/complete`
- `POST` `/api/rounds/{id}/pairings`
- `GET` `/api/rounds/{id}/time-expired`
- `GET/POST` `/api/matches/`
- `GET` `/api/matches/{id}/`
- `POST` `/api/matches/{id}/transition/pending-to-active`
- `POST` `/api/matches/{id}/transition/active-to-completed`
- `POST` `/api/matches/{id}/transition/active-to-draw`
- `POST` `/api/matches/{id}/transition/pending-to-b_y_e`
- `POST` `/api/matches/{id}/record`
- `POST` `/api/matches/{id}/finalize`
- `GET` `/api/matches/{id}/winner`
- `POST` `/api/matches/{id}/concede`
- `POST` `/api/matches/{id}/draw`
- `GET/POST` `/api/games/`
- `GET` `/api/games/{id}/`
- `POST` `/api/games/{id}/winner`
- `GET` `/api/games/{id}/duration`
- `GET/POST` `/api/tournament_prizes/`
- `GET/PUT/PATCH/DELETE` `/api/tournament_prizes/{id}/`
- `GET` `/api/prizes/{id}/applies`
- `POST` `/api/prizes/{id}/award`
- `GET` `/api/awarded_prizes/`
- `GET` `/api/awarded_prizes/{id}/`
- `POST` `/api/awarded-prizes/{id}/claim`

### Marketplace BC
- `GET/POST` `/api/products/`
- `GET/PUT/PATCH` `/api/products/{id}/`
- `POST` `/api/products/{id}/activate`
- `POST` `/api/products/{id}/deactivate`
- `PATCH` `/api/products/{id}/discount`
- `POST` `/api/products/{id}/restock`
- `GET` `/api/products/{id}/effective-price`
- `GET` `/api/products/{id}/in-stock`
- `GET/POST` `/api/orders/`
- `GET` `/api/orders/{id}/`
- `POST` `/api/orders/{id}/transition/pending-to-paid`
- `POST` `/api/orders/{id}/transition/paid-to-processing`
- `POST` `/api/orders/{id}/transition/processing-to-shipped`
- `POST` `/api/orders/{id}/transition/shipped-to-completed`
- `POST` `/api/orders/{id}/transition/pending-to-cancelled`
- `POST` `/api/orders/{id}/transition/paid-to-cancelled`
- `POST` `/api/orders/{id}/transition/completed-to-refunded`
- `DELETE` `/api/orders/{id}/cancel`
- `POST` `/api/orders/{id}/pay`
- `POST` `/api/orders/{id}/process-payment`
- `GET` `/api/orders/{id}/total`
- `PATCH` `/api/orders/{id}/discount`
- `POST` `/api/orders/{id}/refund`
- `GET/POST` `/api/order_items/`
- `GET/DELETE` `/api/order_items/{id}/`
- `GET` `/api/order-items/{id}/total`
- `GET/POST` `/api/coupons/`
- `GET/PUT/PATCH` `/api/coupons/{id}/`
- `GET` `/api/coupons/{id}/valid`
- `GET` `/api/coupons/{id}/applicable`
- `POST` `/api/coupons/{id}/redeem`
- `POST` `/api/coupons/{id}/deactivate`
- `GET/POST` `/api/trade_listings/`
- `GET/PATCH` `/api/trade_listings/{id}/`
- `POST` `/api/trade_listings/{id}/transition/pending-to-active`
- `POST` `/api/trade_listings/{id}/transition/active-to-sold`
- `POST` `/api/trade_listings/{id}/transition/active-to-expired`
- `POST` `/api/trade_listings/{id}/transition/active-to-cancelled`
- `POST` `/api/trade-listings/{id}/close`
- `PATCH` `/api/trade-listings/{id}/extend`
- `DELETE` `/api/trade-listings/{id}/cancel`
- `GET` `/api/trade-listings/{id}/expired`
- `POST` `/api/trade-listings/{id}/finalize`
- `GET/POST` `/api/trade_bids/`
- `GET` `/api/trade_bids/{id}/`
- `GET` `/api/bids/{id}/outbid`
- `DELETE` `/api/bids/{id}`
- `GET` `/api/trade_transactions/`
- `GET` `/api/trade_transactions/{id}/`
- `POST` `/api/transactions/{id}/complete`
- `POST` `/api/transactions/{id}/refund`
- `POST` `/api/transactions/{id}/dispute`
- `GET` `/api/transactions/{id}/seller-net`
- `GET` `/api/card_price_histories/`
- `GET` `/api/card_price_histories/{id}/`
- `GET` `/api/price-history/{id}/change`
- `GET` `/api/price-history/{id}/spike`
- `GET/POST` `/api/trade_disputes/`
- `GET` `/api/trade_disputes/{id}/`
- `POST` `/api/trade_disputes/{id}/transition/open-to-under_review`
- `POST` `/api/trade_disputes/{id}/transition/under_review-to-resolved`
- `POST` `/api/trade_disputes/{id}/transition/under_review-to-escalated`
- `POST` `/api/trade_disputes/{id}/transition/escalated-to-resolved`
- `POST` `/api/disputes/{id}/escalate`
- `POST` `/api/disputes/{id}/resolve`
- `POST` `/api/disputes/{id}/close`
- `POST` `/api/disputes/{id}/review`

### Content BC
- `GET/POST` `/api/draft_sessions/`
- `GET` `/api/draft_sessions/{id}/`
- `POST` `/api/draft_sessions/{id}/transition/waiting_for_players-to-drafting`
- `POST` `/api/draft_sessions/{id}/transition/drafting-to-completed`
- `POST` `/api/draft_sessions/{id}/transition/drafting-to-abandoned`
- `POST` `/api/draft_sessions/{id}/transition/waiting_for_players-to-abandoned`
- `POST` `/api/draft-sessions/{id}/start`
- `POST` `/api/draft-sessions/{id}/abandon`
- `POST` `/api/draft-sessions/{id}/complete`
- `GET` `/api/draft-sessions/{id}/full`
- `GET/POST` `/api/draft_participants/`
- `GET` `/api/draft_participants/{id}/`
- `POST` `/api/draft-participants/{id}/pick`
- `GET` `/api/draft-participants/{id}/card-count`
- `GET` `/api/draft_picks/`
- `GET` `/api/draft_picks/{id}/`
- `GET` `/api/draft-picks/{id}/first-pick`
- `GET/POST` `/api/articles/`
- `GET/PUT/PATCH` `/api/articles/{id}/`
- `POST` `/api/articles/{id}/transition/draft-to-published`
- `POST` `/api/articles/{id}/transition/published-to-archived`
- `POST` `/api/articles/{id}/transition/archived-to-draft`
- `POST` `/api/articles/{id}/publish`
- `POST` `/api/articles/{id}/archive`
- `POST` `/api/articles/{id}/view`
- `POST` `/api/articles/{id}/like`
- `DELETE` `/api/articles/{id}/like`
- `GET` `/api/articles/{id}/reading-time`
- `GET/POST` `/api/article_tags/`
- `GET/PATCH/DELETE` `/api/article_tags/{id}/`
- `PATCH` `/api/article-tags/{id}/rename`
- `GET` `/api/article-tags/{id}/article-count`
- `GET/POST` `/api/article_tag_assignments/`
- `GET/DELETE` `/api/article_tag_assignments/{id}/`
- `GET/POST` `/api/article_comments/`
- `GET/DELETE` `/api/article_comments/{id}/`
- `POST` `/api/comments/{id}/hide`
- `POST` `/api/comments/{id}/unhide`
- `GET` `/api/comments/{id}/is-reply`
- `GET/POST` `/api/streams/`
- `GET/PUT/PATCH` `/api/streams/{id}/`
- `POST` `/api/streams/{id}/transition/scheduled-to-live`
- `POST` `/api/streams/{id}/transition/live-to-ended`
- `POST` `/api/streams/{id}/live`
- `POST` `/api/streams/{id}/end`
- `PATCH` `/api/streams/{id}/viewers`
- `GET` `/api/streams/{id}/duration`

## Architecture

Bounded Contexts:

- **Cards BC** (`cards/`) — Card, CardSet, CardRuling, CardAbility, Deck, DeckCard, DeckSideboardCard, DeckTag, DeckTagAssignment
- **Players BC** (`players/`) — Player, PlayerSeasonStats, PlayerCollection, Friendship, Achievement, PlayerAchievement, CraftingRecipe, CraftingIngredient
- **Tournaments BC** (`tournaments/`) — Season, Tournament, TournamentJudge, TournamentRegistration, TournamentRound, Match, Game, TournamentPrize, AwardedPrize
- **Marketplace BC** (`marketplace/`) — Product, Order, OrderItem, Coupon, TradeListing, TradeBid, TradeTransaction, CardPriceHistory, TradeDispute
- **Content BC** (`content/`) — DraftSession, DraftParticipant, DraftPick, Article, ArticleTag, ArticleTagAssignment, ArticleComment, Stream

## Docker

```bash
docker build -t cards-project .
docker run -p 8080:8080 cards-project
```

## CI

GitHub Actions workflow in `.github/workflows/ci.yml` — runs on push and pull_request:
compiles with rebar3 and executes eunit test suite.
