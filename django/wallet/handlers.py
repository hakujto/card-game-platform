"""
Domain event handlers for the Wallet BC bounded context.
Each handler subscribes to an event emitted in this or another bounded context.
"""



def on_order_paid(event):
    """Listens to OrderPaid; runs deduct_credits_if_platform_payment."""
    # TODO: wire up dispatch from OrderPaid to this handler
    # TODO: implement deduct_credits_if_platform_payment
    raise NotImplementedError


def on_tournament_completed(event):
    """Listens to TournamentCompleted; runs distribute_prize_credits."""
    # TODO: wire up dispatch from TournamentCompleted to this handler
    # TODO: implement distribute_prize_credits
    raise NotImplementedError
