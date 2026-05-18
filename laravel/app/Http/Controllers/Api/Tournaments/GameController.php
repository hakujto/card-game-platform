<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\Game;
use App\Models\Tournaments\MatchRecord;
use App\Models\Players\Player;

class GameController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Game::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'game_number' => 'required|integer',
            'winner_side' => 'nullable|string|in:Player1,Player2,Draw|max:20',
            'turns_played' => 'nullable|integer',
            'duration_seconds' => 'nullable|integer',
            'ended_by' => 'nullable|string|in:Normal,Timeout,Concession,DrawOffer|max:20',
            'replay_url' => 'nullable|string|url|max:200',
            'match_id' => 'required|exists:matches,id',
            'winner_id' => 'nullable|exists:players,id',
        ]);
        $item = Game::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(Game $game): JsonResponse
    {
        return response()->json($game);
    }

    public function update(Request $request, Game $game): JsonResponse
    {
        $validated = $request->validate([
            'game_number' => 'sometimes|nullable|integer',
            'winner_side' => 'sometimes|nullable|string|max:20',
            'turns_played' => 'sometimes|nullable|integer',
            'duration_seconds' => 'sometimes|nullable|integer',
            'ended_by' => 'sometimes|nullable|string|max:20',
            'replay_url' => 'sometimes|nullable|string|url|max:200',
            'match_id' => 'sometimes|nullable|exists:matches,id',
            'winner_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $game->update($validated);
        $game->validateRules();
        try {
            $game->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($game);
    }

    public function destroy(Game $game): JsonResponse
    {
        $game->delete();
        return response()->json(null, 204);
    }
    public function recordWinner(Request $request, Game $game): JsonResponse
    {
        $winner_side = $request->input('winner_side');
        $game->recordWinner($winner_side);
        $game->save();
        return response()->json(null, 204);
    }

    public function durationMinutes(Request $request, Game $game): JsonResponse
    {
        $result = $game->durationMinutes();
        $game->save();
        return response()->json(['result' => $result]);
    }
}
