<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\MatchRecord;
use App\Models\Tournaments\TournamentRound;
use App\Models\Players\Player;

class MatchRecordController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(MatchRecord::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'table_number' => 'nullable|integer|max:200',
            'status' => 'required|string|in:Pending,Active,Completed,BYE,Draw|max:20',
            'player1_wins' => 'required|integer|max:200',
            'player2_wins' => 'required|integer|max:200',
            'started_at' => 'nullable|date|max:200',
            'ended_at' => 'nullable|date|max:200',
            'result_notes' => 'nullable|string|max:200',
            'round_id' => 'required|exists:tournament_rounds,id',
            'player1_id' => 'required|exists:players,id',
            'player2_id' => 'nullable|exists:players,id',
        ]);
        $item = MatchRecord::create($validated);
        return response()->json($item, 201);
    }

    public function show(MatchRecord $matchRecord): JsonResponse
    {
        return response()->json($matchRecord);
    }

    public function update(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $validated = $request->validate([
            'table_number' => 'sometimes|nullable|integer|max:200',
            'status' => 'sometimes|nullable|string|max:20',
            'player1_wins' => 'sometimes|nullable|integer|max:200',
            'player2_wins' => 'sometimes|nullable|integer|max:200',
            'started_at' => 'sometimes|nullable|date|max:200',
            'ended_at' => 'sometimes|nullable|date|max:200',
            'result_notes' => 'sometimes|nullable|string|max:200',
            'round_id' => 'sometimes|nullable|exists:tournament_rounds,id',
            'player1_id' => 'sometimes|nullable|exists:players,id',
            'player2_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $matchRecord->update($validated);
        return response()->json($matchRecord);
    }

    public function destroy(MatchRecord $matchRecord): JsonResponse
    {
        $matchRecord->delete();
        return response()->json(null, 204);
    }
}
