<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Serializer\Annotation\SerializedName;
use App\Repository\Players\PlayerRepository;
use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\User;
use App\Entity\Cards\Deck;
use App\Entity\Tournaments\Tournament;
use App\Entity\Tournaments\TournamentJudge;
use App\Entity\Tournaments\TournamentRegistration;
use App\Entity\Tournaments\MatchRecord;
use App\Entity\Tournaments\Game;
use App\Entity\Tournaments\AwardedPrize;
use App\Entity\Marketplace\Order;
use App\Entity\Marketplace\TradeListing;
use App\Entity\Marketplace\TradeBid;
use App\Entity\Marketplace\TradeTransaction;
use App\Entity\Marketplace\TradeDispute;
use App\Entity\Content\DraftParticipant;
use App\Entity\Content\Article;
use App\Entity\Content\ArticleComment;
use App\Entity\Content\Stream;

#[ORM\Entity(repositoryClass: PlayerRepository::class)]
#[ORM\Table(name: 'player')]
#[ORM\HasLifecycleCallbacks]
#[UniqueEntity(fields: ['displayName'], message: 'display_name must be unique')]
class Player
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['player:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 50, unique: true)]
    #[Groups(['player:read', 'player:write'])]
    private string $displayName = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['player:read', 'player:write'])]
    private string $rank = 'Bronze';

    #[ORM\Column(type: 'integer')]
    #[Groups(['player:read', 'player:write'])]
    private int $rating = 1000;

    #[ORM\Column(type: 'integer')]
    #[Groups(['player:read', 'player:write'])]
    private int $peakRating = 1000;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['player:read', 'player:write'])]
    private ?string $bio = null;

    #[ORM\Column(type: 'string', length: 2, nullable: true)]
    #[Groups(['player:read', 'player:write'])]
    private ?string $countryCode = null;

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['player:read', 'player:write'])]
    private ?string $avatarUrl = null;

    #[ORM\Column(type: 'string', length: 20, nullable: true)]
    #[Groups(['player:read', 'player:write'])]
    private ?string $preferredFormat = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['player:read', 'player:write'])]
    private bool $isVerified = false;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[SerializedName('createdAt')]
    #[Groups(['player:read', 'player:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[SerializedName('lastActiveAt')]
    #[Groups(['player:read', 'player:write'])]
    private ?\DateTimeInterface $lastActiveAt = null;

    #[ORM\OneToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: true, unique: true, onDelete: 'CASCADE')]
    private ?User $user = null;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: Deck::class)]
    private Collection $decks;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: PlayerSeasonStats::class)]
    private Collection $seasonStats;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: PlayerCollection::class)]
    private Collection $collection;

    #[ORM\OneToMany(mappedBy: 'requester', targetEntity: Friendship::class)]
    private Collection $sentFriendRequests;

    #[ORM\OneToMany(mappedBy: 'receiver', targetEntity: Friendship::class)]
    private Collection $receivedFriendRequests;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: PlayerAchievement::class)]
    private Collection $achievementRecords;

    #[ORM\OneToMany(mappedBy: 'organizer', targetEntity: Tournament::class)]
    private Collection $organizedTournaments;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: TournamentJudge::class)]
    private Collection $judgeRoles;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: TournamentRegistration::class)]
    private Collection $tournamentRegistrations;

    #[ORM\OneToMany(mappedBy: 'player1', targetEntity: MatchRecord::class)]
    private Collection $matchesAsPlayer1;

    #[ORM\OneToMany(mappedBy: 'player2', targetEntity: MatchRecord::class)]
    private Collection $matchesAsPlayer2;

    #[ORM\OneToMany(mappedBy: 'winner', targetEntity: Game::class)]
    private Collection $wonGames;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: AwardedPrize::class)]
    private Collection $awardedPrizes;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: Order::class)]
    private Collection $orders;

    #[ORM\OneToMany(mappedBy: 'seller', targetEntity: TradeListing::class)]
    private Collection $tradeListings;

    #[ORM\OneToMany(mappedBy: 'bidder', targetEntity: TradeBid::class)]
    private Collection $bids;

    #[ORM\OneToMany(mappedBy: 'buyer', targetEntity: TradeTransaction::class)]
    private Collection $purchases;

    #[ORM\OneToMany(mappedBy: 'seller', targetEntity: TradeTransaction::class)]
    private Collection $sales;

    #[ORM\OneToMany(mappedBy: 'openedBy', targetEntity: TradeDispute::class)]
    private Collection $disputesOpened;

    #[ORM\OneToMany(mappedBy: 'resolvedBy', targetEntity: TradeDispute::class)]
    private Collection $disputesResolved;

    #[ORM\OneToMany(mappedBy: 'player', targetEntity: DraftParticipant::class)]
    private Collection $draftSessions;

    #[ORM\OneToMany(mappedBy: 'author', targetEntity: Article::class)]
    private Collection $articles;

    #[ORM\OneToMany(mappedBy: 'author', targetEntity: ArticleComment::class)]
    private Collection $articleComments;

    #[ORM\OneToMany(mappedBy: 'streamer', targetEntity: Stream::class)]
    private Collection $streams;

    public function __construct()
    {
        $this->decks = new ArrayCollection();
        $this->seasonStats = new ArrayCollection();
        $this->collection = new ArrayCollection();
        $this->sentFriendRequests = new ArrayCollection();
        $this->receivedFriendRequests = new ArrayCollection();
        $this->achievementRecords = new ArrayCollection();
        $this->organizedTournaments = new ArrayCollection();
        $this->judgeRoles = new ArrayCollection();
        $this->tournamentRegistrations = new ArrayCollection();
        $this->matchesAsPlayer1 = new ArrayCollection();
        $this->matchesAsPlayer2 = new ArrayCollection();
        $this->wonGames = new ArrayCollection();
        $this->awardedPrizes = new ArrayCollection();
        $this->orders = new ArrayCollection();
        $this->tradeListings = new ArrayCollection();
        $this->bids = new ArrayCollection();
        $this->purchases = new ArrayCollection();
        $this->sales = new ArrayCollection();
        $this->disputesOpened = new ArrayCollection();
        $this->disputesResolved = new ArrayCollection();
        $this->draftSessions = new ArrayCollection();
        $this->articles = new ArrayCollection();
        $this->articleComments = new ArrayCollection();
        $this->streams = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getDisplayName(): string
    {
        return $this->displayName;
    }

    public function setDisplayName(string $displayName): static
    {
        $this->displayName = $displayName;
        return $this;
    }

    public function getRank(): string
    {
        return $this->rank;
    }

    public function setRank(string $rank): static
    {
        $this->rank = $rank;
        return $this;
    }

    public function getRating(): int
    {
        return $this->rating;
    }

    public function setRating(int $rating): static
    {
        $this->rating = $rating;
        return $this;
    }

    public function getPeakRating(): int
    {
        return $this->peakRating;
    }

    public function setPeakRating(int $peakRating): static
    {
        $this->peakRating = $peakRating;
        return $this;
    }

    public function getBio(): ?string
    {
        return $this->bio;
    }

    public function setBio(?string $bio): static
    {
        $this->bio = $bio;
        return $this;
    }

    public function getCountryCode(): ?string
    {
        return $this->countryCode;
    }

    public function setCountryCode(?string $countryCode): static
    {
        $this->countryCode = $countryCode;
        return $this;
    }

    public function getAvatarUrl(): ?string
    {
        return $this->avatarUrl;
    }

    public function setAvatarUrl(?string $avatarUrl): static
    {
        $this->avatarUrl = $avatarUrl;
        return $this;
    }

    public function getPreferredFormat(): ?string
    {
        return $this->preferredFormat;
    }

    public function setPreferredFormat(?string $preferredFormat): static
    {
        $this->preferredFormat = $preferredFormat;
        return $this;
    }

    public function getIsVerified(): bool
    {
        return $this->isVerified;
    }

    public function setIsVerified(bool $isVerified): static
    {
        $this->isVerified = $isVerified;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeInterface
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?\DateTimeInterface $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getLastActiveAt(): ?\DateTimeInterface
    {
        return $this->lastActiveAt;
    }

    public function setLastActiveAt(?\DateTimeInterface $lastActiveAt): static
    {
        $this->lastActiveAt = $lastActiveAt;
        return $this;
    }

    #[Groups(['player:read'])]
    public function getUserId(): ?int
    {
        return $this->user?->getId();
    }

    public function getUser(): ?User
    {
        return $this->user;
    }

    public function setUser(?User $user): static
    {
        $this->user = $user;
        return $this;
    }

    public function getDecks(): Collection
    {
        return $this->decks;
    }

    public function getSeasonStats(): Collection
    {
        return $this->seasonStats;
    }

    public function getCollection(): Collection
    {
        return $this->collection;
    }

    public function getSentFriendRequests(): Collection
    {
        return $this->sentFriendRequests;
    }

    public function getReceivedFriendRequests(): Collection
    {
        return $this->receivedFriendRequests;
    }

    public function getAchievementRecords(): Collection
    {
        return $this->achievementRecords;
    }

    public function getOrganizedTournaments(): Collection
    {
        return $this->organizedTournaments;
    }

    public function getJudgeRoles(): Collection
    {
        return $this->judgeRoles;
    }

    public function getTournamentRegistrations(): Collection
    {
        return $this->tournamentRegistrations;
    }

    public function getMatchesAsPlayer1(): Collection
    {
        return $this->matchesAsPlayer1;
    }

    public function getMatchesAsPlayer2(): Collection
    {
        return $this->matchesAsPlayer2;
    }

    public function getWonGames(): Collection
    {
        return $this->wonGames;
    }

    public function getAwardedPrizes(): Collection
    {
        return $this->awardedPrizes;
    }

    public function getOrders(): Collection
    {
        return $this->orders;
    }

    public function getTradeListings(): Collection
    {
        return $this->tradeListings;
    }

    public function getBids(): Collection
    {
        return $this->bids;
    }

    public function getPurchases(): Collection
    {
        return $this->purchases;
    }

    public function getSales(): Collection
    {
        return $this->sales;
    }

    public function getDisputesOpened(): Collection
    {
        return $this->disputesOpened;
    }

    public function getDisputesResolved(): Collection
    {
        return $this->disputesResolved;
    }

    public function getDraftSessions(): Collection
    {
        return $this->draftSessions;
    }

    public function getArticles(): Collection
    {
        return $this->articles;
    }

    public function getArticleComments(): Collection
    {
        return $this->articleComments;
    }

    public function getStreams(): Collection
    {
        return $this->streams;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Rating must be between 0 and 9999")]
    public function isRatingRangeValid(): bool
    {
        return ($this->getRating() === null || ($this->getRating() >= 0 && $this->getRating() <= 9999));
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Peak rating must be greater than or equal to current rating")]
    public function isPeakRatingGteRatingValid(): bool
    {
        return ($this->getPeakRating() === null || ($this->getRating() !== null && $this->getPeakRating() >= $this->getRating()));
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Display name must not be empty")]
    public function isDisplayNameNotEmptyValid(): bool
    {
        return $this->getDisplayName() !== null;
    }

    // ── Business operations ──────────────────────────────────────────

    public function promote(): mixed
    {
        // TODO: implement promote
        return null;
    }

    public function demote(): mixed
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

    public function winRate(): mixed
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
    #[ORM\PostPersist]
    public function initializeCollection(): void
    {
        // TODO: implement initialize_collection
    }

    #[ORM\PostUpdate]
    public function updateRank(): void
    {
        // TODO: implement update_rank
    }

}
