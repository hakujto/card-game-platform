<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\PlayerSeasonStats;
use App\Models\Players\Player;
use App\Models\Tournaments\Season;

class PlayerSeasonStatsController extends Controller
{

    public function index(): JsonResponse
    {
        return response()->json(PlayerSeasonStats::all());
    }

    public function show(PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        return response()->json($playerSeasonStats);
    }

    public function winRate(Request $request, PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $result = $playerSeasonStats->winRate();
        $playerSeasonStats->save();
        return response()->json(['result' => $result]);
    }

    public function addPoints(Request $request, PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $points = $request->input('points');
        $playerSeasonStats->addPoints($points);
        $playerSeasonStats->save();
        return response()->json(null, 204);
    }

    public function recordTournamentWin(Request $request, PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $playerSeasonStats->recordTournamentWin();
        $playerSeasonStats->save();
        return response()->json(null, 204);
    }
}
