<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class CardSet extends Model
{
    protected $table = 'card_sets';

    protected $fillable = ['name', 'code', 'release_date', 'rotation_date', 'set_type', 'total_cards', 'is_rotated', 'description', 'logo_url'];

    protected $casts = [
        'release_date' => 'date',
        'rotation_date' => 'date',
        'is_rotated' => 'boolean',
    ];

    const SET_TYPE_VALUES = ['Core', 'Expansion', 'Supplemental', 'Masters', 'Draft'];

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->total_cards === null || $this->total_cards > 0))) {
            $errors['total_cards_positive'] = 'Card set must have at least one card';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->rotation_date !== null && !(($this->rotation_date === null || ($this->release_date !== null && $this->rotation_date > $this->release_date)))) {
            throw new \RuntimeException('Rotation date must be after release date');
        }
        if ($this->is_rotated === true && $this->rotation_date === null) {
            throw new \RuntimeException('Rotated set must have a rotation date');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function isLegalInStandard(): bool
    {
        throw new \RuntimeException('is_legal_in_standard not implemented');
    }

    public function isLegalInFormat($format): bool
    {
        throw new \RuntimeException('is_legal_in_format not implemented');
    }

    public function cardCountByRarity($rarity): int
    {
        throw new \RuntimeException('card_count_by_rarity not implemented');
    }

    public function rotateOut(): void
    {
        throw new \RuntimeException('rotate_out not implemented');
    }

}
