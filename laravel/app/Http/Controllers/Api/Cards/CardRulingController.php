<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\CardRuling;
use App\Models\Cards\Card;

class CardRulingController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(CardRuling::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ruling_text' => 'required|string|max:200',
            'published_at' => 'required|date',
            'source' => 'required|string|max:200',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = CardRuling::create($validated);
        return response()->json($item, 201);
    }

    public function show(CardRuling $cardRuling): JsonResponse
    {
        return response()->json($cardRuling);
    }

    public function update(Request $request, CardRuling $cardRuling): JsonResponse
    {
        $validated = $request->validate([
            'ruling_text' => 'sometimes|nullable|string|max:200',
            'published_at' => 'sometimes|nullable|date',
            'source' => 'sometimes|nullable|string|max:200',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $cardRuling->update($validated);
        return response()->json($cardRuling);
    }

    public function destroy(CardRuling $cardRuling): JsonResponse
    {
        $cardRuling->delete();
        return response()->json(null, 204);
    }
}
