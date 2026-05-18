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
            'earned_at' => 'required|date',
            'progress' => 'required|integer',
            'is_completed' => 'required|boolean',
            'player_id' => 'required|exists:players,id',
            'achievement_id' => 'required|exists:achievements,id',
        ]);
        $item = PlayerAchievement::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(PlayerAchievement $playerAchievement): JsonResponse
    {
        return response()->json($playerAchievement);
    }

    public function update(Request $request, PlayerAchievement $playerAchievement): JsonResponse
    {
        $validated = $request->validate([
            'earned_at' => 'sometimes|nullable|date',
            'progress' => 'sometimes|nullable|integer',
            'is_completed' => 'sometimes|nullable|boolean',
            'player_id' => 'sometimes|nullable|exists:players,id',
            'achievement_id' => 'sometimes|nullable|exists:achievements,id',
        ]);
        $playerAchievement->update($validated);
        $playerAchievement->validateRules();
        try {
            $playerAchievement->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($playerAchievement);
    }

    public function destroy(PlayerAchievement $playerAchievement): JsonResponse
    {
        $playerAchievement->delete();
        return response()->json(null, 204);
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
