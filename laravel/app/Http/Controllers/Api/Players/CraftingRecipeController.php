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
            'dust_cost' => 'required|integer|max:200',
            'is_available' => 'required|boolean|max:200',
            'result_card_id' => 'required|exists:cards,id',
        ]);
        $item = CraftingRecipe::create($validated);
        return response()->json($item, 201);
    }

    public function show(CraftingRecipe $craftingRecipe): JsonResponse
    {
        return response()->json($craftingRecipe);
    }

    public function update(Request $request, CraftingRecipe $craftingRecipe): JsonResponse
    {
        $validated = $request->validate([
            'dust_cost' => 'sometimes|nullable|integer|max:200',
            'is_available' => 'sometimes|nullable|boolean|max:200',
            'result_card_id' => 'sometimes|nullable|exists:cards,id',
        ]);
        $craftingRecipe->update($validated);
        return response()->json($craftingRecipe);
    }

    public function destroy(CraftingRecipe $craftingRecipe): JsonResponse
    {
        $craftingRecipe->delete();
        return response()->json(null, 204);
    }
}
