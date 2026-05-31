<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\PlayerAchievement;
use App\Models\Players\Player;
use App\Models\Players\Achievement;

class PlayerAchievementController extends Controller
{

    public function index(): JsonResponse
    {
        return response()->json(PlayerAchievement::all());
    }

    public function show(PlayerAchievement $playerAchievement): JsonResponse
    {
        return response()->json($playerAchievement);
    }

    public function incrementProgress(Request $request, PlayerAchievement $playerAchievement): JsonResponse
    {
        $amount = $request->input('amount');
        $playerAchievement->incrementProgress($amount);
        $playerAchievement->save();
        return response()->json(null, 204);
    }

    public function complete(Request $request, PlayerAchievement $playerAchievement): JsonResponse
    {
        $playerAchievement->complete();
        $playerAchievement->save();
        return response()->json(null, 204);
    }
}
