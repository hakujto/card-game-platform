<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class DeckTag extends Model
{
    protected $table = 'deck_tags';

    protected $fillable = ['name', 'color'];

    // ── Business operations ──────────────────────────────────────────

    public function rename($new_name): void
    {
        throw new \RuntimeException('rename not implemented');
    }

    public function mergeInto($target_tag_id): void
    {
        throw new \RuntimeException('merge_into not implemented');
    }

}
