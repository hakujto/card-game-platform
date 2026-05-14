<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\CardSet;

class CardSetController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(CardSet::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:200',
            'code' => 'required|string|max:10',
            'release_date' => 'required|date',
            'set_type' => 'required|string|in:Core,Expansion,Supplemental,Masters,Draft|max:20',
            'total_cards' => 'required|integer',
            'description' => 'nullable|string|max:200',
            'logo_url' => 'nullable|string|url|max:200',
        ]);
        $item = CardSet::create($validated);
        return response()->json($item, 201);
    }

    public function show(CardSet $cardSet): JsonResponse
    {
        return response()->json($cardSet);
    }

    public function update(Request $request, CardSet $cardSet): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:200',
            'code' => 'sometimes|nullable|string|max:10',
            'release_date' => 'sometimes|nullable|date',
            'set_type' => 'sometimes|nullable|string|max:20',
            'total_cards' => 'sometimes|nullable|integer',
            'description' => 'sometimes|nullable|string|max:200',
            'logo_url' => 'sometimes|nullable|string|url|max:200',
        ]);
        $cardSet->update($validated);
        return response()->json($cardSet);
    }

    public function destroy(CardSet $cardSet): JsonResponse
    {
        $cardSet->delete();
        return response()->json(null, 204);
    }
}
