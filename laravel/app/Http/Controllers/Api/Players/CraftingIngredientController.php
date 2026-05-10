<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\CraftingIngredient;
use App\Models\Players\CraftingRecipe;
use App\Models\Cards\Card;

class CraftingIngredientController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(CraftingIngredient::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'required|integer|max:200',
            'recipe_id' => 'required|exists:crafting_recipes,id',
            'card_id' => 'required|exists:cards,id',
        ]);
        $item = CraftingIngredient::create($validated);
        return response()->json($item, 201);
    }

    public function show(CraftingIngredient $craftingIngredient): JsonResponse
    {
        return response()->json($craftingIngredient);
    }

    public function update(Request $request, CraftingIngredient $craftingIngredient): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => 'sometimes|nullable|integer|max:200',
            'recipe_id' => 'sometimes|nullable|exists:crafting_recipes,id',
            'card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $craftingIngredient->update($validated);
        return response()->json($craftingIngredient);
    }

    public function destroy(CraftingIngredient $craftingIngredient): JsonResponse
    {
        $craftingIngredient->delete();
        return response()->json(null, 204);
    }
}
