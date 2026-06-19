<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\User;
use App\Models\Cards\Deck;
use App\Models\Tournaments\Tournament;
use App\Models\Tournaments\TournamentJudge;
use App\Models\Tournaments\TournamentRegistration;
use App\Models\Tournaments\MatchRecord;
use App\Models\Tournaments\Game;
use App\Models\Tournaments\AwardedPrize;
use App\Models\Marketplace\Order;
use App\Models\Marketplace\TradeListing;
use App\Models\Marketplace\TradeBid;
use App\Models\Marketplace\TradeTransaction;
use App\Models\Marketplace\TradeDispute;
use App\Models\Content\DraftParticipant;
use App\Models\Content\Article;
use App\Models\Content\ArticleComment;
use App\Models\Content\Stream;

class Player extends Model
{
    protected $table = 'players';

    protected $fillable = ['display_name', 'rank', 'rating', 'peak_rating', 'bio', 'country_code', 'avatar_url', 'preferred_format', 'is_verified', 'last_active_at', 'user_id'];

    protected $casts = [
        'is_verified' => 'boolean',
        'last_active_at' => 'datetime',
    ];

    const RANK_VALUES = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Master', 'Grandmaster'];
    const PREFERRED_FORMAT_VALUES = ['Standard', 'Extended', 'Legacy', 'Vintage', 'Commander', 'Draft'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function achievementses(): BelongsToMany
    {
        return $this->belongsToMany(Achievement::class, 'player_achievements', 'player_id', 'achievement_id')->using(PlayerAchievement::class);
    }

    public function friendses(): BelongsToMany
    {
        return $this->belongsToMany(Player::class, 'friendships', 'player_id', 'player_id')->using(Friendship::class);
    }

    public function decks(): HasMany
    {
        return $this->hasMany(Deck::class, 'player_id');
    }

    public function seasonStats(): HasMany
    {
        return $this->hasMany(PlayerSeasonStats::class, 'player_id');
    }

    public function collection(): HasMany
    {
        return $this->hasMany(PlayerCollection::class, 'player_id');
    }

    public function sentFriendRequests(): HasMany
    {
        return $this->hasMany(Friendship::class, 'requester_id');
    }

    public function receivedFriendRequests(): HasMany
    {
        return $this->hasMany(Friendship::class, 'receiver_id');
    }

    public function achievementRecords(): HasMany
    {
        return $this->hasMany(PlayerAchievement::class, 'player_id');
    }

    public function organizedTournaments(): HasMany
    {
        return $this->hasMany(Tournament::class, 'organizer_id');
    }

    public function judgeRoles(): HasMany
    {
        return $this->hasMany(TournamentJudge::class, 'player_id');
    }

    public function tournamentRegistrations(): HasMany
    {
        return $this->hasMany(TournamentRegistration::class, 'player_id');
    }

    public function matchesAsPlayer1(): HasMany
    {
        return $this->hasMany(MatchRecord::class, 'player1_id');
    }

    public function matchesAsPlayer2(): HasMany
    {
        return $this->hasMany(MatchRecord::class, 'player2_id');
    }

    public function wonGames(): HasMany
    {
        return $this->hasMany(Game::class, 'winner_id');
    }

    public function awardedPrizes(): HasMany
    {
        return $this->hasMany(AwardedPrize::class, 'player_id');
    }

    public function orders(): HasMany
    {
        return $this->hasMany(Order::class, 'player_id');
    }

    public function tradeListings(): HasMany
    {
        return $this->hasMany(TradeListing::class, 'seller_id');
    }

    public function bids(): HasMany
    {
        return $this->hasMany(TradeBid::class, 'bidder_id');
    }

    public function purchases(): HasMany
    {
        return $this->hasMany(TradeTransaction::class, 'buyer_id');
    }

    public function sales(): HasMany
    {
        return $this->hasMany(TradeTransaction::class, 'seller_id');
    }

    public function disputesOpened(): HasMany
    {
        return $this->hasMany(TradeDispute::class, 'opened_by_id');
    }

    public function disputesResolved(): HasMany
    {
        return $this->hasMany(TradeDispute::class, 'resolved_by_id');
    }

    public function draftSessions(): HasMany
    {
        return $this->hasMany(DraftParticipant::class, 'player_id');
    }

    public function articles(): HasMany
    {
        return $this->hasMany(Article::class, 'author_id');
    }

    public function articleComments(): HasMany
    {
        return $this->hasMany(ArticleComment::class, 'author_id');
    }

    public function streams(): HasMany
    {
        return $this->hasMany(Stream::class, 'streamer_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->rating === null || ($this->rating >= 0 && $this->rating <= 9999)))) {
            $errors['rating_range'] = 'Rating must be between 0 and 9999';
        }
        if (!(($this->peak_rating === null || ($this->rating !== null && $this->peak_rating >= $this->rating)))) {
            $errors['peak_rating_gte_rating'] = 'Peak rating must be greater than or equal to current rating';
        }
        if (!($this->display_name !== null)) {
            $errors['display_name_not_empty'] = 'Display name must not be empty';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function promote(): ?bool
    {
        // TODO: implement promote
        return null;
    }

    public function demote(): ?bool
    {
        // TODO: implement demote
        return null;
    }

    public function recordWin(): void
    {
        // TODO: implement record_win
    }

    public function recordLoss(): void
    {
        // TODO: implement record_loss
    }

    public function winRate(): ?string
    {
        // TODO: implement win_rate
        return null;
    }

    public function verify(): void
    {
        // TODO: implement verify
    }

    public function updateRating($delta): void
    {
        // TODO: implement update_rating
    }

    // ── Lifecycle hooks ──────────────────────────────────────────────
    protected static function boot(): void
    {
        parent::boot();
        static::created(function (self $model) {
            $model->initializeCollection();
        });
        static::updated(function (self $model) {
            $model->updateRank();
        });
    }

    protected function initializeCollection(): void
    {
        // TODO: implement initialize_collection
    }

    protected function updateRank(): void
    {
        // TODO: implement update_rank
    }

}
