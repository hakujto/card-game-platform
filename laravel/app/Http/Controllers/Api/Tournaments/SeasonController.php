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
            'start_date' => 'required|date',
            'end_date' => 'required|date',
            'format' => 'required|string|in:Standard,Extended,Legacy,Vintage,Commander,Draft|max:20',
            'is_active' => 'required|boolean',
            'reward_description' => 'nullable|string|max:200',
        ]);
        $item = Season::create($validated);
        $item->validateRules();

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
            'start_date' => 'sometimes|nullable|date',
            'end_date' => 'sometimes|nullable|date',
            'format' => 'sometimes|nullable|string|max:20',
            'is_active' => 'sometimes|nullable|boolean',
            'reward_description' => 'sometimes|nullable|string|max:200',
        ]);
        $season->update($validated);
        $season->validateRules();

        return response()->json($season);
    }

    public function destroy(Season $season): JsonResponse
    {
        $season->delete();
        return response()->json(null, 204);
    }
    public function activate(Request $request, Season $season): JsonResponse
    {
        $season->activate();
        $season->save();
        return response()->json(null, 204);
    }

    public function deactivate(Request $request, Season $season): JsonResponse
    {
        $season->deactivate();
        $season->save();
        return response()->json(null, 204);
    }

    public function finalizeRewards(Request $request, Season $season): JsonResponse
    {
        $season->finalizeRewards();
        $season->save();
        return response()->json(null, 204);
    }

    public function isOngoing(Request $request, Season $season): JsonResponse
    {
        $result = $season->isOngoing();
        $season->save();
        return response()->json(['result' => $result]);
    }
}
