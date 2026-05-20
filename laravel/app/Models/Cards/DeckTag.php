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
        // TODO: implement rename
    }

    public function mergeInto($target_tag_id): void
    {
        // TODO: implement merge_into
    }

}
