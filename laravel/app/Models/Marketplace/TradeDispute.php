<?php

namespace App\Models\Marketplace;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class TradeDispute extends Model
{
    protected $table = 'trade_disputes';

    protected $fillable = ['reason', 'description', 'status', 'resolution', 'opened_at', 'resolved_at', 'transaction_id', 'opened_by_id', 'resolved_by_id'];

    protected $casts = [
        'opened_at' => 'datetime',
        'resolved_at' => 'datetime',
    ];

    const REASON_VALUES = ['ItemNotReceived', 'ItemNotAsDescribed', 'FraudSuspected', 'Other'];
    const STATUS_VALUES = ['Open', 'UnderReview', 'Resolved', 'Escalated'];

    public function transaction(): BelongsTo
    {
        return $this->belongsTo(TradeTransaction::class, 'transaction_id');
    }

    public function openedBy(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'opened_by_id');
    }

    public function resolvedBy(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'resolved_by_id');
    }

}
