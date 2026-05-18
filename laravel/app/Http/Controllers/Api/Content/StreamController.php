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
            'viewer_count_peak' => 'required|integer',
            'scheduled_start' => 'required|date',
            'actual_start' => 'nullable|date',
            'ended_at' => 'nullable|date',
            'vod_url' => 'nullable|string|url|max:200',
            'tournament_id' => 'nullable|exists:tournaments,id',
            'streamer_id' => 'required|exists:players,id',
        ]);
        $item = Stream::create($validated);
        $item->validateRules();
        try {
            $item->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

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
            'viewer_count_peak' => 'sometimes|nullable|integer',
            'scheduled_start' => 'sometimes|nullable|date',
            'actual_start' => 'sometimes|nullable|date',
            'ended_at' => 'sometimes|nullable|date',
            'vod_url' => 'sometimes|nullable|string|url|max:200',
            'tournament_id' => 'sometimes|nullable|exists:tournaments,id',
            'streamer_id' => 'sometimes|nullable|exists:players,id',
        ]);
        $stream->update($validated);
        $stream->validateRules();
        try {
            $stream->validateImplies();
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }

        return response()->json($stream);
    }

    public function destroy(Stream $stream): JsonResponse
    {
        $stream->delete();
        return response()->json(null, 204);
    }
    public function goLive(Request $request, Stream $stream): JsonResponse
    {
        $stream->goLive();
        $stream->save();
        return response()->json(null, 204);
    }

    public function end(Request $request, Stream $stream): JsonResponse
    {
        $stream->end();
        $stream->save();
        return response()->json(null, 204);
    }

    public function updateViewerPeak(Request $request, Stream $stream): JsonResponse
    {
        $count = $request->input('count');
        $stream->updateViewerPeak($count);
        $stream->save();
        return response()->json(null, 204);
    }

    public function durationMinutes(Request $request, Stream $stream): JsonResponse
    {
        $result = $stream->durationMinutes();
        $stream->save();
        return response()->json(['result' => $result]);
    }
}
