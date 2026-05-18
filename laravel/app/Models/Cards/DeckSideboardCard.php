<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class DeckSideboardCard extends Model
{
    protected $table = 'deck_sideboard_cards';

    protected $fillable = ['quantity', 'deck_id', 'card_id'];

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
            $errors['quantity_range'] = 'Sideboard card quantity must be between 1 and 4 copies';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function incrementAction($amount): void
    {
        throw new \RuntimeException('increment not implemented');
    }

    public function decrementAction($amount): void
    {
        throw new \RuntimeException('decrement not implemented');
    }

}
