<?php

namespace App\Http\Controllers\Api\Content;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use App\Models\Content\Stream;
use App\Models\Tournaments\Tournament;
use App\Models\Players\Player;

class StreamController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(Stream::all());
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:300',
            'stream_url' => 'required|string|url|max:200',
            'platform' => 'required|string|in:Twitch,YouTube,KickStream,Platform|max:20',
            'status' => 'required|string|in:Scheduled,Live,Ended|max:20',
            'viewer_count_peak' => 'required|integer|max:200',
            'scheduled_start' => 'required|date|max:200',
            'actual_start' => 'nullable|date|max:200',
            'ended_at' => 'nullable|date|max:200',
            'vod_url' => 'nullable|string|url|max:200',
            'tournament_id' => 'nullable|exists:tournaments,id',
            'streamer_id' => 'required|exists:players,id',
        ]);
        $item = Stream::create($validated);
        return response()->json($item, 201);
    }

    public function show(Stream $stream): JsonResponse
    {
        return response()->json($stream);
    }

    public function update(Request $request, Stream $stream): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'sometimes|nullable|string|max:300',
            'stream_url' => 'sometimes|nullable|string|url|max:200',
            'platform' => 'sometimes|nullable|string|max:20',
            'status' => 'sometimes|nullable|string|max:20',
            'viewer_count_peak' => 'sometimes|nullable|integer|max:200',
            'scheduled_start' => 'sometimes|nullable|date|max:200',
            'actual_start' => 'sometimes|nullable|date|max:200',
            'ended_at' => 'sometimes|nullable|date|max:200',
            'vod_url' => 'sometimes|nullable|string|url|max:200',
            'tournament_id' => 'sometimes|nullable|exists:tournaments,id',
            'streamer_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $stream->update($validated);
        return response()->json($stream);
    }

    public function destroy(Stream $stream): JsonResponse
    {
        $stream->delete();
        return response()->json(null, 204);
    }
}
