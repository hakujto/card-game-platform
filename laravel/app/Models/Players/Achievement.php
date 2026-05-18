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

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->points === null || $this->points > 0))) {
            $errors['points_positive'] = 'Achievement must award at least one point';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function pointValue($multiplier): int
    {
        throw new \RuntimeException('point_value not implemented');
    }

    public function reveal(): void
    {
        throw new \RuntimeException('reveal not implemented');
    }

}
