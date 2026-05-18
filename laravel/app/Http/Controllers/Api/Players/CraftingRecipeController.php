<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\CraftingRecipe;
use App\Models\Cards\Card;

class CraftingRecipeController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(CraftingRecipe::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'dust_cost' => 'required|integer',
            'is_available' => 'required|boolean',
            'result_card_id' => 'required|exists:cards,id',
        ]);
        $item = CraftingRecipe::create($validated);
        $item->validateRules();

        return response()->json($item, 201);
    }

    public function show(CraftingRecipe $craftingRecipe): JsonResponse
    {
        return response()->json($craftingRecipe);
    }

    public function update(Request $request, CraftingRecipe $craftingRecipe): JsonResponse
    {
        $validated = $request->validate([
            'dust_cost' => 'sometimes|nullable|integer',
            'is_available' => 'sometimes|nullable|boolean',
            'result_card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $craftingRecipe->update($validated);
        $craftingRecipe->validateRules();

        return response()->json($craftingRecipe);
    }

    public function destroy(CraftingRecipe $craftingRecipe): JsonResponse
    {
        $craftingRecipe->delete();
        return response()->json(null, 204);
    }
    public function canCraft(Request $request, CraftingRecipe $craftingRecipe): JsonResponse
    {
        $result = $craftingRecipe->canCraft();
        $craftingRecipe->save();
        return response()->json(['result' => $result]);
    }

    public function executeCraft(Request $request, CraftingRecipe $craftingRecipe): JsonResponse
    {
        $player_id = $request->input('player_id');
        $craftingRecipe->executeCraft($player_id);
        $craftingRecipe->save();
        return response()->json(null, 204);
    }

    public function disable(Request $request, CraftingRecipe $craftingRecipe): JsonResponse
    {
        $craftingRecipe->disable();
        $craftingRecipe->save();
        return response()->json(null, 204);
    }

    public function enable(Request $request, CraftingRecipe $craftingRecipe): JsonResponse
    {
        $craftingRecipe->enable();
        $craftingRecipe->save();
        return response()->json(null, 204);
    }
}
