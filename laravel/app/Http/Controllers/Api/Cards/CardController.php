<?php

namespace App\Http\Controllers\Api\Cards;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Cards\Card;
use App\Models\Cards\CardSet;

class CardController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Card::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:200',
            'card_type' => 'required|string|in:Creature,Spell,Land,Artifact,Enchantment,Planeswalker|max:20',
            'rarity' => 'required|string|in:Common,Uncommon,Rare,MythicRare,Legendary|max:20',
            'mana_cost' => 'required|integer|max:200',
            'mana_colors' => 'required|string|in:White,Blue,Black,Red,Green,Colorless|max:20',
            'attack' => 'nullable|integer|max:200',
            'defense' => 'nullable|integer|max:200',
            'loyalty' => 'nullable|integer|max:200',
            'description' => 'required|string|max:200',
            'flavor_text' => 'nullable|string|max:200',
            'image_url' => 'nullable|string|url|max:200',
            'artist_name' => 'nullable|string|max:100',
            'legal_formats' => 'required|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'is_banned' => 'required|boolean|max:200',
            'is_restricted' => 'required|boolean|max:200',
            'power_level' => 'required|integer|max:200',
            'set_id' => 'required|exists:card_sets,id',
        ]);
        $item = Card::create($validated);
        return response()->json($item, 201);
    }

    public function show(Card $card): JsonResponse
    {
        return response()->json($card);
    }

    public function update(Request $request, Card $card): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:200',
            'card_type' => 'sometimes|nullable|string|max:20',
            'rarity' => 'sometimes|nullable|string|max:20',
            'mana_cost' => 'sometimes|nullable|integer|max:200',
            'mana_colors' => 'sometimes|nullable|string|max:20',
            'attack' => 'sometimes|nullable|integer|max:200',
            'defense' => 'sometimes|nullable|integer|max:200',
            'loyalty' => 'sometimes|nullable|integer|max:200',
            'description' => 'sometimes|nullable|string|max:200',
            'flavor_text' => 'sometimes|nullable|string|max:200',
            'image_url' => 'sometimes|nullable|string|url|max:200',
            'artist_name' => 'sometimes|nullable|string|max:100',
            'legal_formats' => 'sometimes|nullable|string|max:20',
            'is_banned' => 'sometimes|nullable|boolean|max:200',
            'is_restricted' => 'sometimes|nullable|boolean|max:200',
            'power_level' => 'sometimes|nullable|integer|max:200',
            'set_id' => 'sometimes|nullable|exists:card_sets,id',
        ]);
        $card->update($validated);
        return response()->json($card);
    }

    public function destroy(Card $card): JsonResponse
    {
        $card->delete();
        return response()->json(null, 204);
    }
}
