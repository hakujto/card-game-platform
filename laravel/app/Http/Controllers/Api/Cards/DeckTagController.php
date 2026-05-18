<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\DeckTag;

class DeckTagController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(DeckTag::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:50',
            'color' => 'nullable|string|max:7',
        ]);
        $item = DeckTag::create($validated);
        return response()->json($item, 201);
    }

    public function show(DeckTag $deckTag): JsonResponse
    {
        return response()->json($deckTag);
    }

    public function update(Request $request, DeckTag $deckTag): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:50',
            'color' => 'sometimes|nullable|string|max:7',
        ]);
        $deckTag->update($validated);
        return response()->json($deckTag);
    }

    public function destroy(DeckTag $deckTag): JsonResponse
    {
        $deckTag->delete();
        return response()->json(null, 204);
    }
    public function rename(Request $request, DeckTag $deckTag): JsonResponse
    {
        $new_name = $request->input('new_name');
        $deckTag->rename($new_name);
        $deckTag->save();
        return response()->json(null, 204);
    }

    public function mergeInto(Request $request, DeckTag $deckTag): JsonResponse
    {
        $target_tag_id = $request->input('target_tag_id');
        $deckTag->mergeInto($target_tag_id);
        $deckTag->save();
        return response()->json(null, 204);
    }
}
