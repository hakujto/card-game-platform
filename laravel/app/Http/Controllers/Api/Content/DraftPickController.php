<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\DraftPick;
use App\Models\Content\DraftParticipant;
use App\Models\Cards\Card;

class DraftPickController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(DraftPick::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'pick_number' => 'required|integer',
            'pack_number' => 'required|integer',
            'picked_at' => 'required|date',
            'participant_id' => 'required|exists:draft_participants,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = DraftPick::create($validated);
        $item->validateRules();

        return response()->json($item, 201);
    }

    public function show(DraftPick $draftPick): JsonResponse
    {
        return response()->json($draftPick);
    }

    public function update(Request $request, DraftPick $draftPick): JsonResponse
    {
        $validated = $request->validate([
            'pick_number' => 'sometimes|nullable|integer',
            'pack_number' => 'sometimes|nullable|integer',
            'picked_at' => 'sometimes|nullable|date',
            'participant_id' => 'sometimes|nullable|exists:draft_participants,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $draftPick->update($validated);
        $draftPick->validateRules();

        return response()->json($draftPick);
    }

    public function destroy(DraftPick $draftPick): JsonResponse
    {
        $draftPick->delete();
        return response()->json(null, 204);
    }
    public function isFirstPick(Request $request, DraftPick $draftPick): JsonResponse
    {
        $result = $draftPick->isFirstPick();
        $draftPick->save();
        return response()->json(['result' => $result]);
    }
}
