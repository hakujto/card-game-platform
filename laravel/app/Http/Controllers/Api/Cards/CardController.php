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
            'mana_cost' => 'required|integer',
            'mana_colors' => 'required|string|in:White,Blue,Black,Red,Green,Colorless|max:20',
            'attack' => 'nullable|integer',
            'defense' => 'nullable|integer',
            'loyalty' => 'nullable|integer',
            'description' => 'required|string|max:200',
            'flavor_text' => 'nullable|string|max:200',
            'image_url' => 'nullable|string|url|max:200',
            'artist_name' => 'nullable|string|max:100',
            'legal_formats' => 'required|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'is_banned' => 'required|boolean',
            'is_restricted' => 'required|boolean',
            'power_level' => 'required|integer',
            'set_id' => 'required|exists:card_sets,id',
        ]);
        $item = Card::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

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
            'mana_cost' => 'sometimes|nullable|integer',
            'mana_colors' => 'sometimes|nullable|string|max:20',
            'attack' => 'sometimes|nullable|integer',
            'defense' => 'sometimes|nullable|integer',
            'loyalty' => 'sometimes|nullable|integer',
            'description' => 'sometimes|nullable|string|max:200',
            'flavor_text' => 'sometimes|nullable|string|max:200',
            'image_url' => 'sometimes|nullable|string|url|max:200',
            'artist_name' => 'sometimes|nullable|string|max:100',
            'legal_formats' => 'sometimes|nullable|string|max:20',
            'is_banned' => 'sometimes|nullable|boolean',
            'is_restricted' => 'sometimes|nullable|boolean',
            'power_level' => 'sometimes|nullable|integer',
            'set_id' => 'sometimes|nullable|exists:card_sets,id',
        ]);
        $card->update($validated);
        $card->validateRules();
        try {
            $card->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($card);
    }

    public function destroy(Card $card): JsonResponse
    {
        $card->delete();
        return response()->json(null, 204);
    }
    public function ban(Request $request, Card $card): JsonResponse
    {
        $card->ban();
        $card->save();
        return response()->json(null, 204);
    }

    public function unban(Request $request, Card $card): JsonResponse
    {
        $card->unban();
        $card->save();
        return response()->json(null, 204);
    }

    public function restrict(Request $request, Card $card): JsonResponse
    {
        $card->restrict();
        $card->save();
        return response()->json(null, 204);
    }

    public function unrestrict(Request $request, Card $card): JsonResponse
    {
        $card->unrestrict();
        $card->save();
        return response()->json(null, 204);
    }

    public function calculateValue(Request $request, Card $card): JsonResponse
    {
        $result = $card->calculateValue();
        $card->save();
        return response()->json(['result' => $result]);
    }

    public function applyRarityBonus(Request $request, Card $card): JsonResponse
    {
        $multiplier = $request->input('multiplier');
        $result = $card->applyRarityBonus($multiplier);
        $card->save();
        return response()->json(['result' => $result]);
    }

    public function isLegalInFormat(Request $request, Card $card): JsonResponse
    {
        $result = $card->isLegalInFormat();
        $card->save();
        return response()->json(['result' => $result]);
    }
}
