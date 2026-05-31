<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\AwardedPrize;
use App\Models\Tournaments\TournamentPrize;
use App\Models\Players\Player;

class AwardedPrizeController extends Controller
{

    public function index(): JsonResponse
    {
        return response()->json(AwardedPrize::all());
    }

    public function show(AwardedPrize $awardedPrize): JsonResponse
    {
        return response()->json($awardedPrize);
    }

    public function claim(Request $request, AwardedPrize $awardedPrize): JsonResponse
    {
        $awardedPrize->claim();
        $awardedPrize->save();
        return response()->json(null, 204);
    }
}
