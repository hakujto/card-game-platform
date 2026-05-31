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
            'round_number' => 'required|integer',
            'status' => 'required|string|in:Pending,Active,Completed|max:20',
            'started_at' => 'nullable|date',
            'ended_at' => 'nullable|date',
            'time_limit_minutes' => 'required|integer',
            'tournament_id' => 'required|exists:tournaments,id',
        ]);
        $item = TournamentRound::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(TournamentRound $tournamentRound): JsonResponse
    {
        return response()->json($tournamentRound);
    }

    public function start(Request $request, TournamentRound $tournamentRound): JsonResponse
    {
        $tournamentRound->start();
        $tournamentRound->save();
        return response()->json(null, 204);
    }

    public function complete(Request $request, TournamentRound $tournamentRound): JsonResponse
    {
        $tournamentRound->complete();
        $tournamentRound->save();
        return response()->json(null, 204);
    }

    public function generatePairings(Request $request, TournamentRound $tournamentRound): JsonResponse
    {
        $tournamentRound->generatePairings();
        $tournamentRound->save();
        return response()->json(null, 204);
    }

    public function isTimeExpired(Request $request, TournamentRound $tournamentRound): JsonResponse
    {
        $result = $tournamentRound->isTimeExpired();
        $tournamentRound->save();
        return response()->json(['result' => $result]);
    }
}
