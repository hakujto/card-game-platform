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
            'game_number' => 'required|integer|min:1|max:3',
            'winner_side' => 'nullable|string|in:Player1,Player2,Draw|max:20',
            'complexity_score' => 'nullable',
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
