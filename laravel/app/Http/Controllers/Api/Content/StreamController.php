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

    public function index(Request $request): JsonResponse
    {
        $q = $request->query('q');
        if ($q) {
            $items = Stream::query()
                ->where('title', 'like', '%' . $q . '%')->get();
        } else {
            $items = Stream::all();
        }
        return response()->json($items);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'title' => 'required|string|max:300',
            'stream_url' => 'required|string|url|max:200',
            'status' => 'required|string|in:Scheduled,Live,Ended|max:20',
            'platform' => 'required|string|in:Twitch,YouTube,KickStream,Platform|max:20',
            'language' => 'required|string|in:EN,DE,FR,IT,ES,JP,PT|max:20',
            'is_official' => 'required|boolean',
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
            'status' => 'sometimes|nullable|string|max:20',
            'platform' => 'sometimes|nullable|string|max:20',
            'language' => 'sometimes|nullable|string|max:20',
            'is_official' => 'sometimes|nullable|boolean',
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
    public function transitionScheduledToLive(Stream $stream): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Streamer', 'Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Scheduled -> Live'], 403);
        }
        try {
            $stream->assertTransition('Live');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        try {
            if ($stream->stream_url === null) {
                throw new \RuntimeException('stream_url is required for Scheduled -> Live');
            }
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 422);
        }
        $stream->status = 'Live';
        $stream->goLive(); // @after
        $stream->save();
        return response()->json($stream);
    }

    public function transitionLiveToEnded(Stream $stream): JsonResponse
    {
        if (!in_array(auth()->user()?->role, ['Streamer', 'Admin'], true)) {
            return response()->json(['error' => 'Insufficient role for transition Live -> Ended'], 403);
        }
        try {
            $stream->assertTransition('Ended');
        } catch (\InvalidArgumentException $e) {
            return response()->json(['error' => $e->getMessage()], 409);
        }
        $stream->status = 'Ended';
        $stream->end(); // @after
        $stream->save();
        return response()->json($stream);
    }

    public function transitionEndedToLive(Stream $stream): JsonResponse
    {
        return response()->json(['error' => 'Transition Ended -> Live is not allowed'], 409);
    }
}
