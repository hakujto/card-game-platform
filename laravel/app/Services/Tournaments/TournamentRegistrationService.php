<?php

namespace App\Services\Tournaments;

use App\Models\Tournaments\TournamentRegistration;

class TournamentRegistrationService
{
    public function create(array $data): TournamentRegistration
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TournamentRegistration $tournamentRegistration, array $data): TournamentRegistration
    {
        throw new \LogicException('Not implemented');
    }
    public function withdraw(int $id): void
    {
        $tournamentRegistration = TournamentRegistration::findOrFail($id);
        $tournamentRegistration->withdraw();
        $tournamentRegistration->save();
    }

    public function disqualify(int $id, $reason): void
    {
        $tournamentRegistration = TournamentRegistration::findOrFail($id);
        $tournamentRegistration->disqualify($reason);
        $tournamentRegistration->save();
    }

    public function promoteFromWaitlist(int $id): void
    {
        $tournamentRegistration = TournamentRegistration::findOrFail($id);
        $tournamentRegistration->promoteFromWaitlist();
        $tournamentRegistration->save();
    }
}
