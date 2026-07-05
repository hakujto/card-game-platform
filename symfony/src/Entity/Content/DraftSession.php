<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Serializer\Annotation\SerializedName;
use App\Repository\Content\DraftSessionRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\Cards\CardSet;

#[ORM\Entity(repositoryClass: DraftSessionRepository::class)]
#[ORM\Table(name: 'draft_session')]
class DraftSession
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['draftSession:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private string $status = 'WaitingForPlayers';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private string $draftType = 'Booster';

    #[ORM\Column(type: 'json', nullable: true)]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private ?array $packContents = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private int $seats = 8;

    #[ORM\Column(type: 'integer')]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private int $timePerPickSeconds = 30;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[SerializedName('createdAt')]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[SerializedName('completedAt')]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private ?\DateTimeInterface $completedAt = null;

    #[ORM\ManyToOne(targetEntity: CardSet::class, inversedBy: 'draftSessions')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'RESTRICT')]
    private ?CardSet $cardSet = null;

    #[ORM\OneToMany(mappedBy: 'session', targetEntity: DraftParticipant::class)]
    private Collection $participants;

    public function __construct()
    {
        $this->participants = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getStatus(): string
    {
        return $this->status;
    }

    public function setStatus(string $status): static
    {
        $this->status = $status;
        return $this;
    }

    public function getDraftType(): string
    {
        return $this->draftType;
    }

    public function setDraftType(string $draftType): static
    {
        $this->draftType = $draftType;
        return $this;
    }

    public function getPackContents(): ?array
    {
        return $this->packContents;
    }

    public function setPackContents(?array $packContents): static
    {
        $this->packContents = $packContents;
        return $this;
    }

    public function getSeats(): int
    {
        return $this->seats;
    }

    public function setSeats(int $seats): static
    {
        $this->seats = $seats;
        return $this;
    }

    public function getTimePerPickSeconds(): int
    {
        return $this->timePerPickSeconds;
    }

    public function setTimePerPickSeconds(int $timePerPickSeconds): static
    {
        $this->timePerPickSeconds = $timePerPickSeconds;
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

    public function getCompletedAt(): ?\DateTimeInterface
    {
        return $this->completedAt;
    }

    public function setCompletedAt(?\DateTimeInterface $completedAt): static
    {
        $this->completedAt = $completedAt;
        return $this;
    }

    #[Groups(['draftSession:read'])]
    public function getCardSetId(): ?int
    {
        return $this->cardSet?->getId();
    }

    public function getCardSet(): ?CardSet
    {
        return $this->cardSet;
    }

    public function setCardSet(?CardSet $cardSet): static
    {
        $this->cardSet = $cardSet;
        return $this;
    }

    public function getParticipants(): Collection
    {
        return $this->participants;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Draft session must have between 2 and 16 seats")]
    public function isSeatsRangeValid(): bool
    {
        return ($this->getSeats() === null || ($this->getSeats() >= 2 && $this->getSeats() <= 16));
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Time per pick must be greater than zero")]
    public function isTimePerPickPositiveValid(): bool
    {
        return ($this->getTimePerPickSeconds() === null || $this->getTimePerPickSeconds() > 0);
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getCompletedAt() !== null && !($this->getStatus() === 'COMPLETED')) {
            throw new \DomainException('completed_at can only be set when draft status is Completed');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function start(): void
    {
        // TODO: implement start
    }

    public function abandon(): void
    {
        // TODO: implement abandon
    }

    public function complete(): void
    {
        // TODO: implement complete
    }

    public function isFull(): mixed
    {
        // TODO: implement is_full
        return null;
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static array $ALLOWED_TRANSITIONS = [
        'WaitingForPlayers' => ['Drafting', 'Abandoned'],
        'Drafting' => ['Completed', 'Abandoned'],
    ];

    public function assertTransition(string $from, string $to): void
    {
        $allowed = self::$ALLOWED_TRANSITIONS[$from] ?? [];
        if (!in_array($to, $allowed, true)) {
            throw new \RuntimeException("Transition {$from} -> {$to} not allowed");
        }
    }

}
