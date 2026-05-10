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
            'max_players' => 'required|integer|max:200',
            'entry_fee' => 'required|max:200',
            'prize_pool' => 'required|max:200',
            'start_time' => 'required|date|max:200',
            'end_time' => 'nullable|date|max:200',
            'is_online' => 'required|boolean|max:200',
            'location' => 'nullable|string|max:300',
            'rules_text' => 'nullable|string|max:200',
            'created_at' => 'required|date|max:200',
            'season_id' => 'required|exists:seasons,id',
            'organizer_id' => 'required|exists:players,id',
        ]);
        $item = Tournament::create($validated);
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
            'max_players' => 'sometimes|nullable|integer|max:200',
            'entry_fee' => 'sometimes|nullable|max:200',
            'prize_pool' => 'sometimes|nullable|max:200',
            'start_time' => 'sometimes|nullable|date|max:200',
            'end_time' => 'sometimes|nullable|date|max:200',
            'is_online' => 'sometimes|nullable|boolean|max:200',
            'location' => 'sometimes|nullable|string|max:300',
            'rules_text' => 'sometimes|nullable|string|max:200',
            'created_at' => 'sometimes|nullable|date|max:200',
            'season_id' => 'sometimes|nullable|exists:seasons,id',
            'organizer_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $tournament->update($validated);
        return response()->json($tournament);
    }

    public function destroy(Tournament $tournament): JsonResponse
    {
        $tournament->delete();
        return response()->json(null, 204);
    }
}
