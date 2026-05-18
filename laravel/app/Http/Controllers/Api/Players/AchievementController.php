<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\Achievement;

class AchievementController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Achievement::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:200',
            'description' => 'required|string|max:200',
            'icon_url' => 'nullable|string|url|max:200',
            'points' => 'required|integer',
            'rarity' => 'required|string|in:Common,Uncommon,Rare,Epic,Legendary|max:20',
            'is_hidden' => 'required|boolean',
        ]);
        $item = Achievement::create($validated);
        $item->validateRules();

        return response()->json($item, 201);
    }

    public function show(Achievement $achievement): JsonResponse
    {
        return response()->json($achievement);
    }

    public function update(Request $request, Achievement $achievement): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:200',
            'description' => 'sometimes|nullable|string|max:200',
            'icon_url' => 'sometimes|nullable|string|url|max:200',
            'points' => 'sometimes|nullable|integer',
            'rarity' => 'sometimes|nullable|string|max:20',
            'is_hidden' => 'sometimes|nullable|boolean',
        ]);
        $achievement->update($validated);
        $achievement->validateRules();

        return response()->json($achievement);
    }

    public function destroy(Achievement $achievement): JsonResponse
    {
        $achievement->delete();
        return response()->json(null, 204);
    }
    public function pointValue(Request $request, Achievement $achievement): JsonResponse
    {
        $result = $achievement->pointValue();
        $achievement->save();
        return response()->json(['result' => $result]);
    }

    public function reveal(Request $request, Achievement $achievement): JsonResponse
    {
        $achievement->reveal();
        $achievement->save();
        return response()->json(null, 204);
    }
}
