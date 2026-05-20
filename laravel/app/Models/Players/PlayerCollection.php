<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\Card;

class PlayerCollection extends Model
{
    protected $table = 'player_collections';

    protected $fillable = ['quantity', 'foil', 'condition', 'acquired_at', 'acquired_via', 'player_id', 'card_id'];

    protected $casts = [
        'foil' => 'boolean',
        'acquired_at' => 'datetime',
    ];

    const CONDITION_VALUES = ['Mint', 'NearMint', 'Excellent', 'Good', 'Played'];
    const ACQUIRED_VIA_VALUES = ['Purchase', 'Trade', 'TournamentReward', 'Pack', 'Craft'];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->quantity === null || $this->quantity > 0))) {
            $errors['quantity_positive'] = 'Collection quantity must be greater than zero';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function add($quantity): void
    {
        // TODO: implement add
    }

    public function remove($quantity): void
    {
        // TODO: implement remove
    }

    public function estimatedValue(): ?string
    {
        // TODO: implement estimated_value
        return null;
    }

}
