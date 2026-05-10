from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.db import Base, engine
import app.auth_models  # noqa: F401 — registers User table

# Import all models before create_all so SQLAlchemy resolves cross-app FKs
import cards.models  # noqa: F401
import players.models  # noqa: F401
import tournaments.models  # noqa: F401
import marketplace.models  # noqa: F401
import content.models  # noqa: F401

from cards.router import router_card, router_card_set, router_card_ruling, router_card_ability, router_deck, router_deck_card, router_deck_sideboard_card, router_deck_tag, router_deck_tag_assignment
from players.router import router_player, router_player_season_stats, router_player_collection, router_friendship, router_achievement, router_player_achievement, router_crafting_recipe, router_crafting_ingredient
from tournaments.router import router_season, router_tournament, router_tournament_judge, router_tournament_registration, router_tournament_round, router_match, router_game, router_tournament_prize, router_awarded_prize
from marketplace.router import router_product, router_order, router_order_item, router_coupon, router_tradelisting, router_trade_bid, router_trade_transaction, router_card_price_history, router_trade_dispute
from content.router import router_draft_session, router_draft_participant, router_draft_pick, router_article, router_article_tag, router_article_tag_assignment, router_article_comment, router_stream

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="CardsProject API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router_card)
app.include_router(router_card_set)
app.include_router(router_card_ruling)
app.include_router(router_card_ability)
app.include_router(router_deck)
app.include_router(router_deck_card)
app.include_router(router_deck_sideboard_card)
app.include_router(router_deck_tag)
app.include_router(router_deck_tag_assignment)
app.include_router(router_player)
app.include_router(router_player_season_stats)
app.include_router(router_player_collection)
app.include_router(router_friendship)
app.include_router(router_achievement)
app.include_router(router_player_achievement)
app.include_router(router_crafting_recipe)
app.include_router(router_crafting_ingredient)
app.include_router(router_season)
app.include_router(router_tournament)
app.include_router(router_tournament_judge)
app.include_router(router_tournament_registration)
app.include_router(router_tournament_round)
app.include_router(router_match)
app.include_router(router_game)
app.include_router(router_tournament_prize)
app.include_router(router_awarded_prize)
app.include_router(router_product)
app.include_router(router_order)
app.include_router(router_order_item)
app.include_router(router_coupon)
app.include_router(router_tradelisting)
app.include_router(router_trade_bid)
app.include_router(router_trade_transaction)
app.include_router(router_card_price_history)
app.include_router(router_trade_dispute)
app.include_router(router_draft_session)
app.include_router(router_draft_participant)
app.include_router(router_draft_pick)
app.include_router(router_article)
app.include_router(router_article_tag)
app.include_router(router_article_tag_assignment)
app.include_router(router_article_comment)
app.include_router(router_stream)


@app.get("/")
def root() -> dict:
    return {"status": "ok", "docs": "/docs"}
