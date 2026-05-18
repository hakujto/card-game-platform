<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\TradeBidRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: TradeBidRepository::class)]
#[ORM\Table(name: 'trade_bid')]
class TradeBid
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tradeBid:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['tradeBid:read', 'tradeBid:write'])]
    private string $amount = '0.00';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tradeBid:read', 'tradeBid:write'])]
    private ?\DateTimeInterface $placedAt = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['tradeBid:read', 'tradeBid:write'])]
    private bool $isWinning = false;

    #[ORM\ManyToOne(targetEntity: TradeListing::class, inversedBy: 'bids')]
    #[ORM\JoinColumn(nullable: false)]
    private ?TradeListing $listing = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'bids')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $bidder = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getAmount(): string
    {
        return $this->amount;
    }

    public function setAmount(string $amount): static
    {
        $this->amount = $amount;
        return $this;
    }

    public function getPlacedAt(): ?\DateTimeInterface
    {
        return $this->placedAt;
    }

    public function setPlacedAt(?\DateTimeInterface $placedAt): static
    {
        $this->placedAt = $placedAt;
        return $this;
    }

    public function getIsWinning(): bool
    {
        return $this->isWinning;
    }

    public function setIsWinning(bool $isWinning): static
    {
        $this->isWinning = $isWinning;
        return $this;
    }

    #[Groups(['tradeBid:read'])]
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

    #[Groups(['tradeBid:read'])]
    public function getBidderId(): ?int
    {
        return $this->bidder?->getId();
    }

    public function getBidder(): ?Player
    {
        return $this->bidder;
    }

    public function setBidder(?Player $bidder): static
    {
        $this->bidder = $bidder;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Bid amount must be greater than zero")]
    public function isAmountPositiveValid(): bool
    {
        return ($this->getAmount() === null || (float)$this->getAmount() > (float)0);
    }

    // ── Business operations ──────────────────────────────────────────

    public function outbidBy($newAmount): void
    {
        throw new \RuntimeException('outbid_by not implemented');
    }

    public function retract(): void
    {
        throw new \RuntimeException('retract not implemented');
    }

}
