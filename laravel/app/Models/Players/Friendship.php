<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Friendship extends Model
{
    protected $table = 'friendships';

    protected $fillable = ['status', 'requester_id', 'receiver_id'];

    const STATUS_VALUES = ['Pending', 'Accepted', 'Blocked'];

    public function requester(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'requester_id');
    }

    public function receiver(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'receiver_id');
    }

    // ── Business operations ──────────────────────────────────────────

    public function accept(): void
    {
        throw new \RuntimeException('accept not implemented');
    }

    public function decline(): void
    {
        throw new \RuntimeException('decline not implemented');
    }

    public function block(): void
    {
        throw new \RuntimeException('block not implemented');
    }

}
