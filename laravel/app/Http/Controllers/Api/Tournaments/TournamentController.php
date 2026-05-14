<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\Tournament;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;

class TournamentController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Tournament::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:200',
            'description' => 'nullable|string|max:200',
            'format' => 'required|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'tournament_type' => 'required|string|in:Swiss,SingleElimination,DoubleElimination,RoundRobin|max:20',
            'status' => 'required|string|in:Draft,Registration,Ongoing,Completed,Cancelled|max:20',
            'max_players' => 'required|integer',
            'entry_fee' => 'required',
            'prize_pool' => 'required',
            'start_time' => 'required|date',
            'end_time' => 'nullable|date',
            'is_online' => 'required|boolean',
            'location' => 'nullable|string|max:300',
            'rules_text' => 'nullable|string|max:200',
            'created_at' => 'required|date',
            'season_id' => 'required|exists:seasons,id',
            'organizer_id' => 'required|exists:players,id',
        ]);
        $item = Tournament::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(Tournament $tournament): JsonResponse
    {
        return response()->json($tournament);
    }

    public function update(Request $request, Tournament $tournament): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:200',
            'description' => 'sometimes|nullable|string|max:200',
            'format' => 'sometimes|nullable|string|max:20',
            'tournament_type' => 'sometimes|nullable|string|max:20',
            'status' => 'sometimes|nullable|string|max:20',
            'max_players' => 'sometimes|nullable|integer',
            'entry_fee' => 'sometimes|nullable',
            'prize_pool' => 'sometimes|nullable',
            'start_time' => 'sometimes|nullable|date',
            'end_time' => 'sometimes|nullable|date',
            'is_online' => 'sometimes|nullable|boolean',
            'location' => 'sometimes|nullable|string|max:300',
            'rules_text' => 'sometimes|nullable|string|max:200',
            'created_at' => 'sometimes|nullable|date',
            'season_id' => 'sometimes|nullable|exists:seasons,id',
            'organizer_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $tournament->update($validated);
        $tournament->validateRules();
        try {
            $tournament->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($tournament);
    }

    public function destroy(Tournament $tournament): JsonResponse
    {
        $tournament->delete();
        return response()->json(null, 204);
    }
    public function start(Request $request, Tournament $tournament): JsonResponse
    {
        $tournament->start();
        $tournament->save();
        return response()->json(null, 204);
    }

    public function cancel(Request $request, Tournament $tournament): JsonResponse
    {
        $tournament->cancel();
        $tournament->save();
        return response()->json(null, 204);
    }

    public function complete(Request $request, Tournament $tournament): JsonResponse
    {
        $tournament->complete();
        $tournament->save();
        return response()->json(null, 204);
    }

    public function generateRound(Request $request, Tournament $tournament): JsonResponse
    {
        $tournament->generateRound();
        $tournament->save();
        return response()->json(null, 204);
    }

    public function calculatePrizeDistribution(Request $request, Tournament $tournament): JsonResponse
    {
        $result = $tournament->calculatePrizeDistribution();
        $tournament->save();
        return response()->json(['result' => $result]);
    }
}
