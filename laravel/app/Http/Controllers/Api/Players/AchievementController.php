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
            'points' => 'required|integer|max:200',
            'rarity' => 'required|string|in:Common,Uncommon,Rare,Epic,Legendary|max:20',
            'is_hidden' => 'required|boolean|max:200',
        ]);
        $item = Achievement::create($validated);
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
            'points' => 'sometimes|nullable|integer|max:200',
            'rarity' => 'sometimes|nullable|string|max:20',
            'is_hidden' => 'sometimes|nullable|boolean|max:200',
        ]);
        $achievement->update($validated);
        return response()->json($achievement);
    }

    public function destroy(Achievement $achievement): JsonResponse
    {
        $achievement->delete();
        return response()->json(null, 204);
    }
}
