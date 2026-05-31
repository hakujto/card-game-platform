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
            'status' => $this->status,
            'platform' => $this->platform,
            'language' => $this->language,
            'is_official' => $this->is_official,
            'viewer_count_peak' => $this->viewer_count_peak,
            'scheduledStart' => $this->scheduled_start,
            'actualStart' => $this->actual_start,
            'endedAt' => $this->ended_at,
            'vod_url' => $this->vod_url,
            'tournament_id' => $this->tournament_id,
            'streamer_id' => $this->streamer_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
