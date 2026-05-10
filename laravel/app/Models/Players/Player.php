<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\User;

class Player extends Model
{
    protected $table = 'players';

    protected $fillable = ['display_name', 'rank', 'rating', 'peak_rating', 'bio', 'country_code', 'avatar_url', 'preferred_format', 'is_verified', 'last_active_at', 'user_id'];

    protected $casts = [
        'is_verified' => 'boolean',
        'last_active_at' => 'datetime',
    ];

    const RANK_VALUES = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Master', 'Grandmaster'];
    const PREFERRED_FORMAT_VALUES = ['Standard', 'Extended', 'Legacy', 'Vintage', 'Commander', 'Draft'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function achievementses(): BelongsToMany
    {
        return $this->belongsToMany(Achievement::class, 'player_achievements_pivot', 'player_id', 'achievement_id');
    }

    public function friendses(): BelongsToMany
    {
        return $this->belongsToMany(Player::class, 'player_friends_pivot', 'left_id', 'right_id');
    }

}
