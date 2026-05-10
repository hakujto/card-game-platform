<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Achievement extends Model
{
    protected $table = 'achievements';

    protected $fillable = ['name', 'description', 'icon_url', 'points', 'rarity', 'is_hidden'];

    protected $casts = [
        'is_hidden' => 'boolean',
    ];

    const RARITY_VALUES = ['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary'];

}
