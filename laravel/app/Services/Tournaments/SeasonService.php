<?php

namespace App\Services\Tournaments;

use App\Models\Tournaments\Season;

class SeasonService
{
    public function create(array $data): Season
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Season $season, array $data): Season
    {
        throw new \LogicException('Not implemented');
    }
    public function activate(int $id): void
    {
        $season = Season::findOrFail($id);
        $season->activate();
        $season->save();
    }

    public function deactivate(int $id): void
    {
        $season = Season::findOrFail($id);
        $season->deactivate();
        $season->save();
    }

    public function finalizeRewards(int $id): void
    {
        $season = Season::findOrFail($id);
        $season->finalizeRewards();
        $season->save();
    }
}
