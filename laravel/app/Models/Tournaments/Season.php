<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Season extends Model
{
    protected $table = 'seasons';

    protected $fillable = ['name', 'start_date', 'end_date', 'format', 'is_active', 'reward_description'];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'is_active' => 'boolean',
    ];

    const FORMAT_VALUES = ['Standard', 'Extended', 'Legacy', 'Vintage', 'Commander', 'Draft'];

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->end_date === null || ($this->start_date !== null && $this->end_date > $this->start_date)))) {
            $errors['end_date_after_start_date'] = 'Season end date must be after start date';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function activate(): void
    {
        throw new \RuntimeException('activate not implemented');
    }

    public function deactivate(): void
    {
        throw new \RuntimeException('deactivate not implemented');
    }

    public function finalizeRewards(): void
    {
        throw new \RuntimeException('finalize_rewards not implemented');
    }

    public function isOngoing(): bool
    {
        throw new \RuntimeException('is_ongoing not implemented');
    }

}
