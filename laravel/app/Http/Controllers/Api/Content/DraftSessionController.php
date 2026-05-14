<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\DraftSession;
use App\Models\Cards\CardSet;

class DraftSessionController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(DraftSession::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:WaitingForPlayers,Drafting,Completed,Abandoned|max:20',
            'draft_type' => 'required|string|in:Booster,Cube,Rochester|max:20',
            'seats' => 'required|integer',
            'created_at' => 'required|date',
            'completed_at' => 'nullable|date',
            'card_set_id' => 'required|exists:card_sets,id',
        ]);
        $item = DraftSession::create($validated);
        return response()->json($item, 201);
    }

    public function show(DraftSession $draftSession): JsonResponse
    {
        return response()->json($draftSession);
    }

    public function update(Request $request, DraftSession $draftSession): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'sometimes|nullable|string|max:20',
            'draft_type' => 'sometimes|nullable|string|max:20',
            'seats' => 'sometimes|nullable|integer',
            'created_at' => 'sometimes|nullable|date',
            'completed_at' => 'sometimes|nullable|date',
            'card_set_id' => 'sometimes|nullable|exists:card_sets,id',
        ]);
        $draftSession->update($validated);
        return response()->json($draftSession);
    }

    public function destroy(DraftSession $draftSession): JsonResponse
    {
        $draftSession->delete();
        return response()->json(null, 204);
    }
    public function start(Request $request, DraftSession $draftSession): JsonResponse
    {
        $draftSession->start();
        $draftSession->save();
        return response()->json(null, 204);
    }

    public function abandon(Request $request, DraftSession $draftSession): JsonResponse
    {
        $draftSession->abandon();
        $draftSession->save();
        return response()->json(null, 204);
    }

    public function complete(Request $request, DraftSession $draftSession): JsonResponse
    {
        $draftSession->complete();
        $draftSession->save();
        return response()->json(null, 204);
    }
}
