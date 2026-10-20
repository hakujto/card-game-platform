// Tournament domain events

export interface TournamentCompleted {
  readonly type: 'TournamentCompleted';
  readonly tournamentId: number;
  readonly seasonId: number;
  readonly completedAt: string;
}

export interface PlayerRegistered {
  readonly type: 'PlayerRegistered';
  readonly tournamentId: number;
  readonly playerId: number;
  readonly registeredAt: string;
}
