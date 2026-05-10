<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Tournaments\Tournament;
use App\Models\Players\Player;

class Stream extends Model
{
    protected $table = 'streams';

    protected $fillable = ['title', 'stream_url', 'platform', 'status', 'viewer_count_peak', 'scheduled_start', 'actual_start', 'ended_at', 'vod_url', 'tournament_id', 'streamer_id'];

    protected $casts = [
        'scheduled_start' => 'datetime',
        'actual_start' => 'datetime',
        'ended_at' => 'datetime',
    ];

    const PLATFORM_VALUES = ['Twitch', 'YouTube', 'KickStream', 'Platform'];
    const STATUS_VALUES = ['Scheduled', 'Live', 'Ended'];

    public function tournament(): BelongsTo
    {
        return $this->belongsTo(Tournament::class, 'tournament_id');
    }

    public function streamer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'streamer_id');
    }

}
