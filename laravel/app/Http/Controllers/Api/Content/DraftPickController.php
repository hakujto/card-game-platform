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
            'pick_number' => 'required|integer|max:200',
            'pack_number' => 'required|integer|max:200',
            'picked_at' => 'required|date|max:200',
            'participant_id' => 'required|exists:draft_participants,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = DraftPick::create($validated);
        return response()->json($item, 201);
    }

    public function show(DraftPick $draftPick): JsonResponse
    {
        return response()->json($draftPick);
    }

    public function update(Request $request, DraftPick $draftPick): JsonResponse
    {
        $validated = $request->validate([
            'pick_number' => 'sometimes|nullable|integer|max:200',
            'pack_number' => 'sometimes|nullable|integer|max:200',
            'picked_at' => 'sometimes|nullable|date|max:200',
            'participant_id' => 'sometimes|nullable|exists:draft_participants,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $draftPick->update($validated);
        return response()->json($draftPick);
    }

    public function destroy(DraftPick $draftPick): JsonResponse
    {
        $draftPick->delete();
        return response()->json(null, 204);
    }
}
