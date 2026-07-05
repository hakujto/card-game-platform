"""
Domain event handlers for the Players BC bounded context.
Each handler subscribes to an event emitted in this or another bounded context.
"""



def on_tournament_completed(event):
    """Listens to TournamentCompleted; runs sync_season_stats."""
    # TODO: wire up dispatch from TournamentCompleted to this handler
    # TODO: implement sync_season_stats
    raise NotImplementedError


def on_player_registered(event):
    """Listens to PlayerRegistered; runs update_registration_count."""
    # TODO: wire up dispatch from PlayerRegistered to this handler
    # TODO: implement update_registration_count
    raise NotImplementedError
