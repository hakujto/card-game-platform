<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\TournamentRegistration;
use App\Models\Tournaments\Tournament;
use App\Models\Players\Player;
use App\Models\Cards\Deck;

class TournamentRegistrationController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(TournamentRegistration::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:Registered,Waitlisted,Withdrawn,Disqualified|max:20',
            'seed' => 'nullable|integer',
            'final_standing' => 'nullable|integer',
            'points_earned' => 'required|integer',
            'registered_at' => 'required|date',
            'tournament_id' => 'required|exists:tournaments,id',
            'player_id' => 'required|exists:players,id',
            'deck_id' => 'required|exists:decks,id',
        ]);
        $item = TournamentRegistration::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($item, 201);
    }

    public function show(TournamentRegistration $tournamentRegistration): JsonResponse
    {
        return response()->json($tournamentRegistration);
    }

    public function update(Request $request, TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'sometimes|nullable|string|max:20',
            'seed' => 'sometimes|nullable|integer',
            'final_standing' => 'sometimes|nullable|integer',
            'points_earned' => 'sometimes|nullable|integer',
            'registered_at' => 'sometimes|nullable|date',
            'tournament_id' => 'sometimes|nullable|exists:tournaments,id',
            'player_id' => 'sometimes|nullable|exists:players,id',
            'deck_id' => 'sometimes|nullable|exists:decks,id',
        ]);
        $tournamentRegistration->update($validated);
        $tournamentRegistration->validateRules();
        try {
            $tournamentRegistration->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($tournamentRegistration);
    }

    public function destroy(TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $tournamentRegistration->delete();
        return response()->json(null, 204);
    }
    public function withdraw(Request $request, TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $tournamentRegistration->withdraw();
        $tournamentRegistration->save();
        return response()->json(null, 204);
    }

    public function disqualify(Request $request, TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $reason = $request->input('reason');
        $tournamentRegistration->disqualify($reason);
        $tournamentRegistration->save();
        return response()->json(null, 204);
    }

    public function promoteFromWaitlist(Request $request, TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $tournamentRegistration->promoteFromWaitlist();
        $tournamentRegistration->save();
        return response()->json(null, 204);
    }
}
