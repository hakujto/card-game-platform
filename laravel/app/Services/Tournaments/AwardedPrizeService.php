<?php

namespace App\Services\Tournaments;

use App\Models\Tournaments\AwardedPrize;

class AwardedPrizeService
{
    public function create(array $data): AwardedPrize
    {
        throw new \LogicException('Not implemented');
    }

    public function update(AwardedPrize $awardedPrize, array $data): AwardedPrize
    {
        throw new \LogicException('Not implemented');
    }
    public function claim(int $id): void
    {
        $awardedPrize = AwardedPrize::findOrFail($id);
        $awardedPrize->claim();
        $awardedPrize->save();
    }

    // triggered by @on(claimed = true)
    public function setClaimed(int $id, string $value): void
    {
        $awardedPrize = AwardedPrize::findOrFail($id);
        $awardedPrize->claimed = $value;
        if ($value === 'true') {
            $awardedPrize->claim();
        }
        $awardedPrize->save();
    }
}
