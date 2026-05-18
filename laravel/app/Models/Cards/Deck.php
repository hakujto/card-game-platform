<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class Deck extends Model
{
    protected $table = 'decks';

    protected $fillable = ['name', 'description', 'format', 'is_public', 'is_tournament_legal', 'archetype', 'wins', 'losses', 'draws', 'player_id'];

    protected $casts = [
        'is_public' => 'boolean',
        'is_tournament_legal' => 'boolean',
    ];

    const FORMAT_VALUES = ['Standard', 'Extended', 'Legacy', 'Vintage', 'Commander', 'Draft'];
    const ARCHETYPE_VALUES = ['Aggro', 'Control', 'Midrange', 'Combo', 'Prison', 'Tempo'];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function cardses(): BelongsToMany
    {
        return $this->belongsToMany(Card::class, 'deck_cards_pivot', 'deck_id', 'card_id');
    }

    public function sideboardCardses(): BelongsToMany
    {
        return $this->belongsToMany(Card::class, 'deck_sideboard_cards_pivot', 'deck_id', 'card_id');
    }

    public function tagses(): BelongsToMany
    {
        return $this->belongsToMany(DeckTag::class, 'deck_tags_pivot', 'deck_id', 'deck_tag_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->wins === null || $this->wins >= 0))) {
            $errors['wins_not_negative'] = 'Deck wins count must not be negative';
        }
        if (!(($this->losses === null || $this->losses >= 0))) {
            $errors['losses_not_negative'] = 'Deck losses count must not be negative';
        }
        if (!(($this->draws === null || $this->draws >= 0))) {
            $errors['draws_not_negative'] = 'Deck draws count must not be negative';
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
        if ($this->is_tournament_legal === true && !($this->is_public === true)) {
            throw new \RuntimeException('Tournament-legal deck must be made public');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function validateSize(): bool
    {
        throw new \RuntimeException('validate_size not implemented');
    }

    public function addCard($card_id, $quantity): void
    {
        throw new \RuntimeException('add_card not implemented');
    }

    public function removeCard($card_id): void
    {
        throw new \RuntimeException('remove_card not implemented');
    }

    public function winRate(): string
    {
        throw new \RuntimeException('win_rate not implemented');
    }

    public function clone(): mixed
    {
        throw new \RuntimeException('clone not implemented');
    }

    public function publish(): void
    {
        throw new \RuntimeException('publish not implemented');
    }

    public function unpublish(): void
    {
        throw new \RuntimeException('unpublish not implemented');
    }

    public function certifyTournamentLegal(): bool
    {
        throw new \RuntimeException('certify_tournament_legal not implemented');
    }

}
