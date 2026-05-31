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

    public function recordResult(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $p1_wins = $request->input('p1_wins');
        $p2_wins = $request->input('p2_wins');
        $matchRecord->recordResult($p1_wins, $p2_wins);
        $matchRecord->save();
        return response()->json(null, 204);
    }

    public function finalizeResult(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $matchRecord->finalizeResult();
        $matchRecord->save();
        return response()->json(null, 204);
    }

    public function determineWinner(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $result = $matchRecord->determineWinner();
        $matchRecord->save();
        return response()->json(['result' => $result]);
    }

    public function concede(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $player_id = $request->input('player_id');
        $matchRecord->concede($player_id);
        $matchRecord->save();
        return response()->json(null, 204);
    }

    public function draw(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $matchRecord->draw();
        $matchRecord->save();
        return response()->json(null, 204);
    }
    public function transitionPendingToActive(MatchRecord $matchRecord): JsonResponse
    {
        try {
            $matchRecord->assertTransition('Active');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $matchRecord->status = 'Active';
        $matchRecord->save();
        return response()->json($matchRecord);
    }

    public function transitionActiveToCompleted(MatchRecord $matchRecord): JsonResponse
    {
        try {
            $matchRecord->assertTransition('Completed');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $matchRecord->status = 'Completed';
        $matchRecord->finalizeResult(); // @after
        $matchRecord->save();
        return response()->json($matchRecord);
    }

    public function transitionActiveToDraw(MatchRecord $matchRecord): JsonResponse
    {
        try {
            $matchRecord->assertTransition('Draw');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $matchRecord->status = 'Draw';
        $matchRecord->draw(); // @after
        $matchRecord->save();
        return response()->json($matchRecord);
    }

    public function transitionPendingToBYE(MatchRecord $matchRecord): JsonResponse
    {
        try {
            $matchRecord->assertTransition('BYE');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $matchRecord->status = 'BYE';
        $matchRecord->save();
        return response()->json($matchRecord);
    }

    public function transitionCompletedToActive(MatchRecord $matchRecord): JsonResponse
    {
        return response()->json(['error' => 'Transition Completed -> Active is not allowed'], 409);
    }

    public function transitionDrawToActive(MatchRecord $matchRecord): JsonResponse
    {
        return response()->json(['error' => 'Transition Draw -> Active is not allowed'], 409);
    }

    public function transitionBYEToActive(MatchRecord $matchRecord): JsonResponse
    {
        return response()->json(['error' => 'Transition BYE -> Active is not allowed'], 409);
    }
}
