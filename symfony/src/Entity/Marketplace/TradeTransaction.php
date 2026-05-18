<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\TradeTransactionRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: TradeTransactionRepository::class)]
#[ORM\Table(name: 'trade_transaction')]
class TradeTransaction
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tradeTransaction:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['tradeTransaction:read', 'tradeTransaction:write'])]
    private string $finalPrice = '0.00';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['tradeTransaction:read', 'tradeTransaction:write'])]
    private string $platformFee = '0.00';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tradeTransaction:read', 'tradeTransaction:write'])]
    private string $status = 'Pending';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tradeTransaction:read', 'tradeTransaction:write'])]
    private ?\DateTimeInterface $completedAt = null;

    #[ORM\OneToOne(targetEntity: TradeListing::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?TradeListing $listing = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'purchases')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $buyer = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'sales')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $seller = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getFinalPrice(): string
    {
        return $this->finalPrice;
    }

    public function setFinalPrice(string $finalPrice): static
    {
        $this->finalPrice = $finalPrice;
        return $this;
    }

    public function getPlatformFee(): string
    {
        return $this->platformFee;
    }

    public function setPlatformFee(string $platformFee): static
    {
        $this->platformFee = $platformFee;
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

    public function getCompletedAt(): ?\DateTimeInterface
    {
        return $this->completedAt;
    }

    public function setCompletedAt(?\DateTimeInterface $completedAt): static
    {
        $this->completedAt = $completedAt;
        return $this;
    }

    #[Groups(['tradeTransaction:read'])]
    public function getListingId(): ?int
    {
        return $this->listing?->getId();
    }

    public function getListing(): ?TradeListing
    {
        return $this->listing;
    }

    public function setListing(?TradeListing $listing): static
    {
        $this->listing = $listing;
        return $this;
    }

    #[Groups(['tradeTransaction:read'])]
    public function getBuyerId(): ?int
    {
        return $this->buyer?->getId();
    }

    public function getBuyer(): ?Player
    {
        return $this->buyer;
    }

    public function setBuyer(?Player $buyer): static
    {
        $this->buyer = $buyer;
        return $this;
    }

    #[Groups(['tradeTransaction:read'])]
    public function getSellerId(): ?int
    {
        return $this->seller?->getId();
    }

    public function getSeller(): ?Player
    {
        return $this->seller;
    }

    public function setSeller(?Player $seller): static
    {
        $this->seller = $seller;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Platform fee cannot exceed the final price")]
    public function isFeeNotExceedPriceValid(): bool
    {
        return ($this->getPlatformFee() === null || ($this->getFinalPrice() !== null && (float)$this->getPlatformFee() <= (float)$this->getFinalPrice()));
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Platform fee must not be negative")]
    public function isFeeNotNegativeValid(): bool
    {
        return ($this->getPlatformFee() === null || (float)$this->getPlatformFee() >= (float)0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Transaction final price must be greater than zero")]
    public function isFinalPricePositiveValid(): bool
    {
        return ($this->getFinalPrice() === null || (float)$this->getFinalPrice() > (float)0);
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getStatus() === 'COMPLETED' && $this->getCompletedAt() === null) {
            throw new \DomainException('Completed transaction must have a completed_at timestamp');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function complete(): void
    {
        throw new \RuntimeException('complete not implemented');
    }

    public function refund(): void
    {
        throw new \RuntimeException('refund not implemented');
    }

    public function openDispute($reason): void
    {
        throw new \RuntimeException('open_dispute not implemented');
    }

    public function sellerNet(): void
    {
        throw new \RuntimeException('seller_net not implemented');
    }

}
