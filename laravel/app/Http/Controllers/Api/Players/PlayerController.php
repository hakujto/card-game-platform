<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\Player;
use App\Models\User;

class PlayerController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Player::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'display_name' => 'required|string|max:50',
            'rank' => 'required|string|in:Bronze,Silver,Gold,Platinum,Diamond,Master,Grandmaster|max:20',
            'rating' => 'required|integer|max:200',
            'peak_rating' => 'required|integer|max:200',
            'bio' => 'nullable|string|max:200',
            'country_code' => 'nullable|string|max:2',
            'avatar_url' => 'nullable|string|url|max:200',
            'preferred_format' => 'nullable|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'is_verified' => 'required|boolean|max:200',
            'created_at' => 'required|date|max:200',
            'last_active_at' => 'nullable|date|max:200',
            'user_id' => 'nullable|exists:users,id',
        ]);
        $item = Player::create($validated);
        return response()->json($item, 201);
    }

    public function show(Player $player): JsonResponse
    {
        return response()->json($player);
    }

    public function update(Request $request, Player $player): JsonResponse
    {
        $validated = $request->validate([
            'display_name' => 'sometimes|nullable|string|max:50',
            'rank' => 'sometimes|nullable|string|max:20',
            'rating' => 'sometimes|nullable|integer|max:200',
            'peak_rating' => 'sometimes|nullable|integer|max:200',
            'bio' => 'sometimes|nullable|string|max:200',
            'country_code' => 'sometimes|nullable|string|max:2',
            'avatar_url' => 'sometimes|nullable|string|url|max:200',
            'preferred_format' => 'sometimes|nullable|string|max:20',
            'is_verified' => 'sometimes|nullable|boolean|max:200',
            'created_at' => 'sometimes|nullable|date|max:200',
            'last_active_at' => 'sometimes|nullable|date|max:200',
            'user_id' => 'sometimes|nullable|exists:users,id',
        ]);
        $player->update($validated);
        return response()->json($player);
    }

    public function destroy(Player $player): JsonResponse
    {
        $player->delete();
        return response()->json(null, 204);
    }
}
