<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class PlayerAchievement extends Model
{
    protected $table = 'player_achievements';

    protected $fillable = ['earned_at', 'progress', 'is_completed', 'player_id', 'achievement_id'];

    protected $casts = [
        'earned_at' => 'datetime',
        'is_completed' => 'boolean',
    ];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function achievement(): BelongsTo
    {
        return $this->belongsTo(Achievement::class, 'achievement_id');
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->is_completed === true && !(($this->progress === null || $this->progress > 0))) {
            throw new \RuntimeException('Completed achievement must have progress greater than zero');
        }
    }

}
