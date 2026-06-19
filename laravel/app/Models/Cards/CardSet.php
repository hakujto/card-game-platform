<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Marketplace\Product;
use App\Models\Content\DraftSession;

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

    public function cards(): HasMany
    {
        return $this->hasMany(Card::class, 'set_id');
    }

    public function shopProducts(): HasMany
    {
        return $this->hasMany(Product::class, 'card_set_id');
    }

    public function draftSessions(): HasMany
    {
        return $this->hasMany(DraftSession::class, 'card_set_id');
    }

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

    public function isLegalInStandard(): ?bool
    {
        // TODO: implement is_legal_in_standard
        return null;
    }

    public function isLegalInFormat($format): ?bool
    {
        // TODO: implement is_legal_in_format
        return null;
    }

    public function cardCountByRarity($rarity): ?int
    {
        // TODO: implement card_count_by_rarity
        return null;
    }

    public function rotateOut(): void
    {
        // TODO: implement rotate_out
    }

}
