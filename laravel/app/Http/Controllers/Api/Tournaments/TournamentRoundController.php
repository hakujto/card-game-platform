<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\TournamentRound;
use App\Models\Tournaments\Tournament;

class TournamentRoundController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(TournamentRound::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'round_number' => 'required|integer|max:200',
            'status' => 'required|string|in:Pending,Active,Completed|max:20',
            'started_at' => 'nullable|date|max:200',
            'ended_at' => 'nullable|date|max:200',
            'time_limit_minutes' => 'required|integer|max:200',
            'tournament_id' => 'required|exists:tournaments,id',
        ]);
        $item = TournamentRound::create($validated);
        return response()->json($item, 201);
    }

    public function show(TournamentRound $tournamentRound): JsonResponse
    {
        return response()->json($tournamentRound);
    }

    public function update(Request $request, TournamentRound $tournamentRound): JsonResponse
    {
        $validated = $request->validate([
            'round_number' => 'sometimes|nullable|integer|max:200',
            'status' => 'sometimes|nullable|string|max:20',
            'started_at' => 'sometimes|nullable|date|max:200',
            'ended_at' => 'sometimes|nullable|date|max:200',
            'time_limit_minutes' => 'sometimes|nullable|integer|max:200',
            'tournament_id' => 'sometimes|nullable|exists:tournaments,id',
        ]);
        $tournamentRound->update($validated);
        return response()->json($tournamentRound);
    }

    public function destroy(TournamentRound $tournamentRound): JsonResponse
    {
        $tournamentRound->delete();
        return response()->json(null, 204);
    }
}
