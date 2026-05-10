<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class CardSet extends Model
{
    protected $table = 'card_sets';

    protected $fillable = ['name', 'code', 'release_date', 'set_type', 'total_cards', 'description', 'logo_url'];

    protected $casts = [
        'release_date' => 'date',
    ];

    const SET_TYPE_VALUES = ['Core', 'Expansion', 'Supplemental', 'Masters', 'Draft'];

}
