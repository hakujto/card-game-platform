<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\TradeDisputeRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: TradeDisputeRepository::class)]
#[ORM\Table(name: 'trade_dispute')]
class TradeDispute
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tradeDispute:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tradeDispute:read', 'tradeDispute:write'])]
    private string $reason = '';

    #[ORM\Column(type: 'text')]
    #[Groups(['tradeDispute:read', 'tradeDispute:write'])]
    private string $description = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tradeDispute:read', 'tradeDispute:write'])]
    private string $status = 'Open';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['tradeDispute:read', 'tradeDispute:write'])]
    private ?string $resolution = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tradeDispute:read', 'tradeDispute:write'])]
    private ?\DateTimeInterface $openedAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tradeDispute:read', 'tradeDispute:write'])]
    private ?\DateTimeInterface $resolvedAt = null;

    #[ORM\OneToOne(targetEntity: TradeTransaction::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?TradeTransaction $transaction = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'disputes_opened')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $openedBy = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'disputes_resolved')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Player $resolvedBy = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getReason(): string
    {
        return $this->reason;
    }

    public function setReason(string $reason): static
    {
        $this->reason = $reason;
        return $this;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function setDescription(string $description): static
    {
        $this->description = $description;
        return $this;
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

    public function getResolution(): ?string
    {
        return $this->resolution;
    }

    public function setResolution(?string $resolution): static
    {
        $this->resolution = $resolution;
        return $this;
    }

    public function getOpenedAt(): ?\DateTimeInterface
    {
        return $this->openedAt;
    }

    public function setOpenedAt(?\DateTimeInterface $openedAt): static
    {
        $this->openedAt = $openedAt;
        return $this;
    }

    public function getResolvedAt(): ?\DateTimeInterface
    {
        return $this->resolvedAt;
    }

    public function setResolvedAt(?\DateTimeInterface $resolvedAt): static
    {
        $this->resolvedAt = $resolvedAt;
        return $this;
    }

    #[Groups(['tradeDispute:read'])]
    public function getTransactionId(): ?int
    {
        return $this->transaction?->getId();
    }

    public function getTransaction(): ?TradeTransaction
    {
        return $this->transaction;
    }

    public function setTransaction(?TradeTransaction $transaction): static
    {
        $this->transaction = $transaction;
        return $this;
    }

    #[Groups(['tradeDispute:read'])]
    public function getOpenedById(): ?int
    {
        return $this->openedBy?->getId();
    }

    public function getOpenedBy(): ?Player
    {
        return $this->openedBy;
    }

    public function setOpenedBy(?Player $openedBy): static
    {
        $this->openedBy = $openedBy;
        return $this;
    }

    #[Groups(['tradeDispute:read'])]
    public function getResolvedById(): ?int
    {
        return $this->resolvedBy?->getId();
    }

    public function getResolvedBy(): ?Player
    {
        return $this->resolvedBy;
    }

    public function setResolvedBy(?Player $resolvedBy): static
    {
        $this->resolvedBy = $resolvedBy;
        return $this;
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getResolvedAt() !== null && !($this->getStatus() === 'RESOLVED')) {
            throw new \DomainException('resolved_at_requires_terminal_status');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function escalate(): void
    {
        throw new \RuntimeException('escalate not implemented');
    }

    public function resolve($resolutionText): void
    {
        throw new \RuntimeException('resolve not implemented');
    }

    public function review(): void
    {
        throw new \RuntimeException('review not implemented');
    }

}
