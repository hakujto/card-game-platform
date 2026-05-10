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

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'earned_at' => 'required|date|max:200',
            'progress' => 'required|integer|max:200',
            'is_completed' => 'required|boolean|max:200',
            'player_id' => 'required|exists:players,id',
            'achievement_id' => 'required|exists:achievements,id',
        ]);
        $item = PlayerAchievement::create($validated);
        return response()->json($item, 201);
    }

    public function show(PlayerAchievement $playerAchievement): JsonResponse
    {
        return response()->json($playerAchievement);
    }

    public function update(Request $request, PlayerAchievement $playerAchievement): JsonResponse
    {
        $validated = $request->validate([
            'earned_at' => 'sometimes|nullable|date|max:200',
            'progress' => 'sometimes|nullable|integer|max:200',
            'is_completed' => 'sometimes|nullable|boolean|max:200',
            'player_id' => 'sometimes|nullable|exists:players,id',
            'achievement_id' => 'sometimes|nullable|exists:achievements,id',
        ]);
        $playerAchievement->update($validated);
        return response()->json($playerAchievement);
    }

    public function destroy(PlayerAchievement $playerAchievement): JsonResponse
    {
        $playerAchievement->delete();
        return response()->json(null, 204);
    }
}
