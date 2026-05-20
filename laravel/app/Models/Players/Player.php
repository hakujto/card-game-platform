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

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->rating === null || ($this->rating >= 0 && $this->rating <= 9999)))) {
            $errors['rating_range'] = 'Rating must be between 0 and 9999';
        }
        if (!(($this->peak_rating === null || ($this->rating !== null && $this->peak_rating >= $this->rating)))) {
            $errors['peak_rating_gte_rating'] = 'Peak rating must be greater than or equal to current rating';
        }
        if (!($this->display_name !== null)) {
            $errors['display_name_not_empty'] = 'Display name must not be empty';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function promote(): ?bool
    {
        // TODO: implement promote
        return null;
    }

    public function demote(): ?bool
    {
        // TODO: implement demote
        return null;
    }

    public function recordWin(): void
    {
        // TODO: implement record_win
    }

    public function recordLoss(): void
    {
        // TODO: implement record_loss
    }

    public function winRate(): ?string
    {
        // TODO: implement win_rate
        return null;
    }

    public function verify(): void
    {
        // TODO: implement verify
    }

    public function updateRating($delta): void
    {
        // TODO: implement update_rating
    }

}
