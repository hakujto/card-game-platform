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
            'table_number' => 'nullable|integer',
            'status' => 'required|string|in:Pending,Active,Completed,BYE,Draw|max:20',
            'player1_wins' => 'required|integer',
            'player2_wins' => 'required|integer',
            'started_at' => 'nullable|date',
            'ended_at' => 'nullable|date',
            'result_notes' => 'nullable|string|max:200',
            'round_id' => 'nullable|exists:tournament_rounds,id',
            'player1_id' => 'required|exists:players,id',
            'player2_id' => 'nullable|exists:players,id',
        ]);
        $item = MatchRecord::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(MatchRecord $matchRecord): JsonResponse
    {
        return response()->json($matchRecord);
    }

    public function update(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $validated = $request->validate([
            'table_number' => 'sometimes|nullable|integer',
            'status' => 'sometimes|nullable|string|max:20',
            'player1_wins' => 'sometimes|nullable|integer',
            'player2_wins' => 'sometimes|nullable|integer',
            'started_at' => 'sometimes|nullable|date',
            'ended_at' => 'sometimes|nullable|date',
            'result_notes' => 'sometimes|nullable|string|max:200',
            'round_id' => 'sometimes|nullable|exists:tournament_rounds,id',
            'player1_id' => 'sometimes|nullable|exists:players,id',
            'player2_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $matchRecord->update($validated);
        $matchRecord->validateRules();
        try {
            $matchRecord->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($matchRecord);
    }

    public function destroy(MatchRecord $matchRecord): JsonResponse
    {
        $matchRecord->delete();
        return response()->json(null, 204);
    }
    public function recordResult(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $p1_wins = $request->input('p1_wins');
        $p2_wins = $request->input('p2_wins');
        $matchRecord->recordResult($p1_wins, $p2_wins);
        $matchRecord->save();
        return response()->json(null, 204);
    }

    public function determineWinner(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $result = $matchRecord->determineWinner();
        $matchRecord->save();
        return response()->json(['result' => $result]);
    }

    public function draw(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $matchRecord->draw();
        $matchRecord->save();
        return response()->json(null, 204);
    }
}
