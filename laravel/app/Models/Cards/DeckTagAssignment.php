<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class DeckTagAssignment extends Model
{
    protected $table = 'deck_tag_assignments';

    protected $fillable = ['deck_id', 'tag_id'];

    public function deck(): BelongsTo
    {
        return $this->belongsTo(Deck::class, 'deck_id');
    }

    public function tag(): BelongsTo
    {
        return $this->belongsTo(DeckTag::class, 'tag_id');
    }

}
