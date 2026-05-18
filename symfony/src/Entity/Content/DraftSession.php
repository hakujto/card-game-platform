<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\DraftSessionRepository;
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

    #[ORM\Column(type: 'integer')]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private int $seats = 8;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['draftSession:read', 'draftSession:write'])]
    private ?\DateTimeInterface $completedAt = null;

    #[ORM\ManyToOne(targetEntity: CardSet::class, inversedBy: 'draft_sessions')]
    #[ORM\JoinColumn(nullable: false)]
    private ?CardSet $cardSet = null;

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

    public function getSeats(): int
    {
        return $this->seats;
    }

    public function setSeats(int $seats): static
    {
        $this->seats = $seats;
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

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Draft session must have between 2 and 16 seats")]
    public function isSeatsRangeValid(): bool
    {
        return ($this->getSeats() === null || ($this->getSeats() >= 2 && $this->getSeats() <= 16));
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
        throw new \RuntimeException('start not implemented');
    }

    public function abandon(): void
    {
        throw new \RuntimeException('abandon not implemented');
    }

    public function complete(): void
    {
        throw new \RuntimeException('complete not implemented');
    }

    public function isFull(): void
    {
        throw new \RuntimeException('is_full not implemented');
    }

}
