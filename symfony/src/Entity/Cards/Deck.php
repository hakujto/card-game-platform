<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Serializer\Annotation\SerializedName;
use App\Repository\Cards\DeckRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\Players\Player;
use App\Entity\Tournaments\TournamentRegistration;
use App\Entity\Content\Article;

#[ORM\Entity(repositoryClass: DeckRepository::class)]
#[ORM\Table(name: 'deck')]
#[ORM\HasLifecycleCallbacks]
class Deck
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['deck:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 100)]
    #[Groups(['deck:read', 'deck:write'])]
    private string $name = '';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['deck:read', 'deck:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['deck:read', 'deck:write'])]
    private string $format = 'Standard';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['deck:read', 'deck:write'])]
    private bool $isPublic = false;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['deck:read', 'deck:write'])]
    private bool $isTournamentLegal = false;

    #[ORM\Column(type: 'string', length: 20, nullable: true)]
    #[Groups(['deck:read', 'deck:write'])]
    private ?string $archetype = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['deck:read', 'deck:write'])]
    private int $wins = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['deck:read', 'deck:write'])]
    private int $losses = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['deck:read', 'deck:write'])]
    private int $draws = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[SerializedName('createdAt')]
    #[Groups(['deck:read', 'deck:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[SerializedName('updatedAt')]
    #[Groups(['deck:read', 'deck:write'])]
    private ?\DateTimeInterface $updatedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'decks')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private ?Player $player = null;

    #[ORM\OneToMany(mappedBy: 'deck', targetEntity: DeckCard::class)]
    private Collection $deckCards;

    #[ORM\OneToMany(mappedBy: 'deck', targetEntity: DeckSideboardCard::class)]
    private Collection $sideboardCards;

    #[ORM\OneToMany(mappedBy: 'deck', targetEntity: DeckTagAssignment::class)]
    private Collection $tagAssignments;

    #[ORM\OneToMany(mappedBy: 'deck', targetEntity: TournamentRegistration::class)]
    private Collection $tournamentRegistrations;

    #[ORM\OneToMany(mappedBy: 'featuredDeck', targetEntity: Article::class)]
    private Collection $articles;

    public function __construct()
    {
        $this->deckCards = new ArrayCollection();
        $this->sideboardCards = new ArrayCollection();
        $this->tagAssignments = new ArrayCollection();
        $this->tournamentRegistrations = new ArrayCollection();
        $this->articles = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getFormat(): string
    {
        return $this->format;
    }

    public function setFormat(string $format): static
    {
        $this->format = $format;
        return $this;
    }

    public function getIsPublic(): bool
    {
        return $this->isPublic;
    }

    public function setIsPublic(bool $isPublic): static
    {
        $this->isPublic = $isPublic;
        return $this;
    }

    public function getIsTournamentLegal(): bool
    {
        return $this->isTournamentLegal;
    }

    public function setIsTournamentLegal(bool $isTournamentLegal): static
    {
        $this->isTournamentLegal = $isTournamentLegal;
        return $this;
    }

    public function getArchetype(): ?string
    {
        return $this->archetype;
    }

    public function setArchetype(?string $archetype): static
    {
        $this->archetype = $archetype;
        return $this;
    }

    public function getWins(): int
    {
        return $this->wins;
    }

    public function setWins(int $wins): static
    {
        $this->wins = $wins;
        return $this;
    }

    public function getLosses(): int
    {
        return $this->losses;
    }

    public function setLosses(int $losses): static
    {
        $this->losses = $losses;
        return $this;
    }

    public function getDraws(): int
    {
        return $this->draws;
    }

    public function setDraws(int $draws): static
    {
        $this->draws = $draws;
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

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeInterface $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    #[Groups(['deck:read'])]
    public function getPlayerId(): ?int
    {
        return $this->player?->getId();
    }

    public function getPlayer(): ?Player
    {
        return $this->player;
    }

    public function setPlayer(?Player $player): static
    {
        $this->player = $player;
        return $this;
    }

    public function getDeckCards(): Collection
    {
        return $this->deckCards;
    }

    public function getSideboardCards(): Collection
    {
        return $this->sideboardCards;
    }

    public function getTagAssignments(): Collection
    {
        return $this->tagAssignments;
    }

    public function getTournamentRegistrations(): Collection
    {
        return $this->tournamentRegistrations;
    }

    public function getArticles(): Collection
    {
        return $this->articles;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Deck wins count must not be negative")]
    public function isWinsNotNegativeValid(): bool
    {
        return ($this->getWins() === null || $this->getWins() >= 0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Deck losses count must not be negative")]
    public function isLossesNotNegativeValid(): bool
    {
        return ($this->getLosses() === null || $this->getLosses() >= 0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Deck draws count must not be negative")]
    public function isDrawsNotNegativeValid(): bool
    {
        return ($this->getDraws() === null || $this->getDraws() >= 0);
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getIsTournamentLegal() === true && !($this->getIsPublic() === true)) {
            throw new \DomainException('Tournament-legal deck must be made public');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function validateSize(): mixed
    {
        // TODO: implement validate_size
        return null;
    }

    public function addCard($cardId, $quantity): void
    {
        // TODO: implement add_card
    }

    public function removeCard($cardId): void
    {
        // TODO: implement remove_card
    }

    public function winRate(): mixed
    {
        // TODO: implement win_rate
        return null;
    }

    public function clone(): mixed
    {
        // TODO: implement clone
        return null;
    }

    public function publish(): void
    {
        // TODO: implement publish
    }

    public function unpublish(): void
    {
        // TODO: implement unpublish
    }

    public function certifyTournamentLegal(): mixed
    {
        // TODO: implement certify_tournament_legal
        return null;
    }


    // ── Lifecycle hooks ──────────────────────────────────────────────
    #[ORM\PostPersist]
    #[ORM\PostUpdate]
    public function recalculateTournamentLegal(): void
    {
        // TODO: implement recalculate_tournament_legal
    }

}
