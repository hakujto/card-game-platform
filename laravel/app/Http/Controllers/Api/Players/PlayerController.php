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
            'rating' => 'required|integer',
            'peak_rating' => 'required|integer',
            'bio' => 'nullable|string|max:200',
            'country_code' => 'nullable|string|max:2',
            'avatar_url' => 'nullable|string|url|max:200',
            'preferred_format' => 'nullable|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'is_verified' => 'required|boolean',
            'created_at' => 'required|date',
            'last_active_at' => 'nullable|date',
            'user_id' => 'nullable|exists:users,id',
        ]);
        $item = Player::create($validated);
        $item->validateRules();

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
            'rating' => 'sometimes|nullable|integer',
            'peak_rating' => 'sometimes|nullable|integer',
            'bio' => 'sometimes|nullable|string|max:200',
            'country_code' => 'sometimes|nullable|string|max:2',
            'avatar_url' => 'sometimes|nullable|string|url|max:200',
            'preferred_format' => 'sometimes|nullable|string|max:20',
            'is_verified' => 'sometimes|nullable|boolean',
            'created_at' => 'sometimes|nullable|date',
            'last_active_at' => 'sometimes|nullable|date',
            'user_id' => 'sometimes|nullable|exists:users,id',
        ]);
        $player->update($validated);
        $player->validateRules();

        return response()->json($player);
    }

    public function destroy(Player $player): JsonResponse
    {
        $player->delete();
        return response()->json(null, 204);
    }
    public function promote(Request $request, Player $player): JsonResponse
    {
        $result = $player->promote();
        $player->save();
        return response()->json(['result' => $result]);
    }

    public function demote(Request $request, Player $player): JsonResponse
    {
        $result = $player->demote();
        $player->save();
        return response()->json(['result' => $result]);
    }

    public function recordWin(Request $request, Player $player): JsonResponse
    {
        $player->recordWin();
        $player->save();
        return response()->json(null, 204);
    }

    public function recordLoss(Request $request, Player $player): JsonResponse
    {
        $player->recordLoss();
        $player->save();
        return response()->json(null, 204);
    }

    public function winRate(Request $request, Player $player): JsonResponse
    {
        $result = $player->winRate();
        $player->save();
        return response()->json(['result' => $result]);
    }

    public function verify(Request $request, Player $player): JsonResponse
    {
        $player->verify();
        $player->save();
        return response()->json(null, 204);
    }

    public function updateRating(Request $request, Player $player): JsonResponse
    {
        $delta = $request->input('delta');
        $player->updateRating($delta);
        $player->save();
        return response()->json(null, 204);
    }
}
