<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class DeckCard extends Model
{
    protected $table = 'deck_cards';

    protected $fillable = ['quantity', 'is_commander', 'deck_id', 'card_id'];

    protected $casts = [
        'is_commander' => 'boolean',
    ];

    public function deck(): BelongsTo
    {
        return $this->belongsTo(Deck::class, 'deck_id');
    }

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->quantity === null || ($this->quantity >= 1 && $this->quantity <= 4)))) {
            $errors['quantity_range'] = 'A deck can contain between 1 and 4 copies of a card';
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
        if ($this->is_commander === true && !($this->quantity === 1)) {
            throw new \RuntimeException('Commander card must appear exactly once in the deck');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function incrementAction($amount): void
    {
        // TODO: implement increment
    }

    public function decrementAction($amount): void
    {
        // TODO: implement decrement
    }

}
