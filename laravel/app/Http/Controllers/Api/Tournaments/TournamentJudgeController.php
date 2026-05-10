<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\TournamentJudge;
use App\Models\Tournaments\Tournament;
use App\Models\Players\Player;

class TournamentJudgeController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(TournamentJudge::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'role' => 'required|string|in:HeadJudge,Judge,ScorekeeperJudge|max:20',
            'tournament_id' => 'required|exists:tournaments,id',
            'player_id' => 'required|exists:players,id',
        ]);
        $item = TournamentJudge::create($validated);
        return response()->json($item, 201);
    }

    public function show(TournamentJudge $tournamentJudge): JsonResponse
    {
        return response()->json($tournamentJudge);
    }

    public function update(Request $request, TournamentJudge $tournamentJudge): JsonResponse
    {
        $validated = $request->validate([
            'role' => 'sometimes|nullable|string|max:20',
            'tournament_id' => 'sometimes|nullable|exists:tournaments,id',
            'player_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $tournamentJudge->update($validated);
        return response()->json($tournamentJudge);
    }

    public function destroy(TournamentJudge $tournamentJudge): JsonResponse
    {
        $tournamentJudge->delete();
        return response()->json(null, 204);
    }
}
