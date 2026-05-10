<?php

namespace App\Http\Controllers\Api\Tournaments;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Tournaments\Season;

class SeasonController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Season::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:200',
            'start_date' => 'required|date|max:200',
            'end_date' => 'required|date|max:200',
            'format' => 'required|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'is_active' => 'required|boolean|max:200',
            'reward_description' => 'nullable|string|max:200',
        ]);
        $item = Season::create($validated);
        return response()->json($item, 201);
    }

    public function show(Season $season): JsonResponse
    {
        return response()->json($season);
    }

    public function update(Request $request, Season $season): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'sometimes|nullable|string|max:200',
            'start_date' => 'sometimes|nullable|date|max:200',
            'end_date' => 'sometimes|nullable|date|max:200',
            'format' => 'sometimes|nullable|string|max:20',
            'is_active' => 'sometimes|nullable|boolean|max:200',
            'reward_description' => 'sometimes|nullable|string|max:200',
        ]);
        $season->update($validated);
        return response()->json($season);
    }

    public function destroy(Season $season): JsonResponse
    {
        $season->delete();
        return response()->json(null, 204);
    }
}
