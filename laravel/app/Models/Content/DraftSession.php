<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\CardSet;

class DraftSession extends Model
{
    protected $table = 'draft_sessions';

    protected $fillable = ['status', 'draft_type', 'seats', 'completed_at', 'card_set_id'];

    protected $casts = [
        'completed_at' => 'datetime',
    ];

    const STATUS_VALUES = ['WaitingForPlayers', 'Drafting', 'Completed', 'Abandoned'];
    const DRAFT_TYPE_VALUES = ['Booster', 'Cube', 'Rochester'];

    public function cardSet(): BelongsTo
    {
        return $this->belongsTo(CardSet::class, 'card_set_id');
    }

}
