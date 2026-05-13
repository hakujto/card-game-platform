<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Players\PlayerRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\User;

#[ORM\Entity(repositoryClass: PlayerRepository::class)]
#[ORM\Table(name: 'player')]
class Player
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['player:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 50)]
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
    #[Groups(['player:read', 'player:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['player:read', 'player:write'])]
    private ?\DateTimeInterface $lastActiveAt = null;

    #[ORM\OneToOne(targetEntity: User::class)]
    #[ORM\JoinColumn(nullable: true)]
    private ?User $user = null;

    #[ORM\ManyToOne(targetEntity: PlayerSeasonStats::class, inversedBy: 'player')]
    #[ORM\JoinColumn(nullable: false)]
    private ?PlayerSeasonStats $seasonStats = null;

    #[ORM\ManyToMany(targetEntity: Achievement::class)]
    #[ORM\JoinTable(name: 'player_achievements_m2m')]
    private Collection $achievements;

    #[ORM\ManyToMany(targetEntity: Player::class)]
    #[ORM\JoinTable(name: 'player_friends_m2m')]
    private Collection $friends;

    public function __construct()
    {
        $this->achievements = new ArrayCollection();
        $this->friends = new ArrayCollection();
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

    #[Groups(['player:read'])]
    public function getSeasonStatsId(): ?int
    {
        return $this->seasonStats?->getId();
    }

    public function getSeasonStats(): ?PlayerSeasonStats
    {
        return $this->seasonStats;
    }

    public function setSeasonStats(?PlayerSeasonStats $seasonStats): static
    {
        $this->seasonStats = $seasonStats;
        return $this;
    }

    public function getAchievements(): Collection
    {
        return $this->achievements;
    }

    public function addAchievements(Achievement $item): static
    {
        if (!$this->achievements->contains($item)) {
            $this->achievements->add($item);
        }
        return $this;
    }

    public function removeAchievements(Achievement $item): static
    {
        $this->achievements->removeElement($item);
        return $this;
    }

    public function getFriends(): Collection
    {
        return $this->friends;
    }

    public function addFriends(Player $item): static
    {
        if (!$this->friends->contains($item)) {
            $this->friends->add($item);
        }
        return $this;
    }

    public function removeFriends(Player $item): static
    {
        $this->friends->removeElement($item);
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function promote(): void
    {
        throw new \RuntimeException('promote not implemented');
    }

    public function demote(): void
    {
        throw new \RuntimeException('demote not implemented');
    }

    public function recordWin(): void
    {
        throw new \RuntimeException('record_win not implemented');
    }

    public function recordLoss(): void
    {
        throw new \RuntimeException('record_loss not implemented');
    }

    public function winRate(): void
    {
        throw new \RuntimeException('win_rate not implemented');
    }

    public function verify(): void
    {
        throw new \RuntimeException('verify not implemented');
    }

    public function updateRating($delta): void
    {
        throw new \RuntimeException('update_rating not implemented');
    }

}
