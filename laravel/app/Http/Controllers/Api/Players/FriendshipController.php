<?php

namespace App\Http\Controllers\Api\Players;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Players\Friendship;
use App\Models\Players\Player;

class FriendshipController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Friendship::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:Pending,Accepted,Blocked|max:20',
            'created_at' => 'required|date|max:200',
            'requester_id' => 'required|exists:players,id',
            'receiver_id' => 'required|exists:players,id',
        ]);
        $item = Friendship::create($validated);
        return response()->json($item, 201);
    }

    public function show(Friendship $friendship): JsonResponse
    {
        return response()->json($friendship);
    }

    public function update(Request $request, Friendship $friendship): JsonResponse
    {
        $validated = $request->validate([
            'status' => 'sometimes|nullable|string|max:20',
            'created_at' => 'sometimes|nullable|date|max:200',
            'requester_id' => 'sometimes|nullable|exists:players,id',
            'receiver_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $friendship->update($validated);
        return response()->json($friendship);
    }

    public function destroy(Friendship $friendship): JsonResponse
    {
        $friendship->delete();
        return response()->json(null, 204);
    }
}
