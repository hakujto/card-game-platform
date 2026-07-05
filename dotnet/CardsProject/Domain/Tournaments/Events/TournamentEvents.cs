namespace CardsProject.Domain.Tournaments.Events;

public sealed record TournamentCompleted(
    int TournamentId,
    int SeasonId,
    DateTime CompletedAt
);

public sealed record PlayerRegistered(
    int TournamentId,
    int PlayerId,
    DateTime RegisteredAt
);
