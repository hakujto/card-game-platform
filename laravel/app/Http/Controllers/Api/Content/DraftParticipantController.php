<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\DraftParticipant;
use App\Models\Content\DraftSession;
use App\Models\Players\Player;

class DraftParticipantController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(DraftParticipant::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'seat_number' => 'required|integer',
            'joined_at' => 'required|date',
            'session_id' => 'nullable|exists:draft_sessions,id',
            'player_id' => 'required|exists:players,id',
        ]);
        $item = DraftParticipant::create($validated);
        $item->validateRules();

        return response()->json($item, 201);
    }

    public function show(DraftParticipant $draftParticipant): JsonResponse
    {
        return response()->json($draftParticipant);
    }

    public function update(Request $request, DraftParticipant $draftParticipant): JsonResponse
    {
        $validated = $request->validate([
            'seat_number' => 'sometimes|nullable|integer',
            'joined_at' => 'sometimes|nullable|date',
            'session_id' => 'sometimes|nullable|exists:draft_sessions,id',
            'player_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $draftParticipant->update($validated);
        $draftParticipant->validateRules();

        return response()->json($draftParticipant);
    }

    public function destroy(DraftParticipant $draftParticipant): JsonResponse
    {
        $draftParticipant->delete();
        return response()->json(null, 204);
    }
    public function pickCard(Request $request, DraftParticipant $draftParticipant): JsonResponse
    {
        $card_id = $request->input('card_id');
        $pack_number = $request->input('pack_number');
        $draftParticipant->pickCard($card_id, $pack_number);
        $draftParticipant->save();
        return response()->json(null, 204);
    }

    public function draftedCardCount(Request $request, DraftParticipant $draftParticipant): JsonResponse
    {
        $result = $draftParticipant->draftedCardCount();
        $draftParticipant->save();
        return response()->json(['result' => $result]);
    }
}
