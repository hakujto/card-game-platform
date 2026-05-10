<?php

namespace App\Http\Resources\Content;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StreamResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'stream_url' => $this->stream_url,
            'platform' => $this->platform,
            'status' => $this->status,
            'viewer_count_peak' => $this->viewer_count_peak,
            'scheduled_start' => $this->scheduled_start,
            'actual_start' => $this->actual_start,
            'ended_at' => $this->ended_at,
            'vod_url' => $this->vod_url,
            'tournament_id' => $this->tournament_id,
            'streamer_id' => $this->streamer_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
