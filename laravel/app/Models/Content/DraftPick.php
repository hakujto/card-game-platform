<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\Card;

class DraftPick extends Model
{
    protected $table = 'draft_picks';

    protected $fillable = ['pick_number', 'pack_number', 'picked_at', 'participant_id', 'card_id'];

    protected $casts = [
        'picked_at' => 'datetime',
    ];

    public function participant(): BelongsTo
    {
        return $this->belongsTo(DraftParticipant::class, 'participant_id');
    }

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

}
