<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\TradelistingRepository;
use App\Entity\Players\Player;
use App\Entity\Cards\Card;

#[ORM\Entity(repositoryClass: TradelistingRepository::class)]
#[ORM\Table(name: 'tradelisting')]
class Tradelisting
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tradelisting:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private string $listingType = 'FixedPrice';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2, nullable: true)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private ?string $askingPrice = null;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2, nullable: true)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private ?string $auctionStartPrice = null;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2, nullable: true)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private ?string $auctionCurrentBid = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private ?\DateTimeInterface $auctionEndTime = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private bool $foil = false;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private string $condition = 'Mint';

    #[ORM\Column(type: 'integer')]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private int $quantity = 1;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private string $status = 'Active';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tradelisting:read', 'tradelisting:write'])]
    private ?\DateTimeInterface $expiresAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'trade_listings')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $seller = null;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'trade_listings')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $card = null;

    #[ORM\ManyToOne(targetEntity: TradeBid::class, inversedBy: 'listing')]
    #[ORM\JoinColumn(nullable: true)]
    private ?TradeBid $bids = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getListingType(): string
    {
        return $this->listingType;
    }

    public function setListingType(string $listingType): static
    {
        $this->listingType = $listingType;
        return $this;
    }

    public function getAskingPrice(): ?string
    {
        return $this->askingPrice;
    }

    public function setAskingPrice(?string $askingPrice): static
    {
        $this->askingPrice = $askingPrice;
        return $this;
    }

    public function getAuctionStartPrice(): ?string
    {
        return $this->auctionStartPrice;
    }

    public function setAuctionStartPrice(?string $auctionStartPrice): static
    {
        $this->auctionStartPrice = $auctionStartPrice;
        return $this;
    }

    public function getAuctionCurrentBid(): ?string
    {
        return $this->auctionCurrentBid;
    }

    public function setAuctionCurrentBid(?string $auctionCurrentBid): static
    {
        $this->auctionCurrentBid = $auctionCurrentBid;
        return $this;
    }

    public function getAuctionEndTime(): ?\DateTimeInterface
    {
        return $this->auctionEndTime;
    }

    public function setAuctionEndTime(?\DateTimeInterface $auctionEndTime): static
    {
        $this->auctionEndTime = $auctionEndTime;
        return $this;
    }

    public function getFoil(): bool
    {
        return $this->foil;
    }

    public function setFoil(bool $foil): static
    {
        $this->foil = $foil;
        return $this;
    }

    public function getCondition(): string
    {
        return $this->condition;
    }

    public function setCondition(string $condition): static
    {
        $this->condition = $condition;
        return $this;
    }

    public function getQuantity(): int
    {
        return $this->quantity;
    }

    public function setQuantity(int $quantity): static
    {
        $this->quantity = $quantity;
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

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;
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

    public function getExpiresAt(): ?\DateTimeInterface
    {
        return $this->expiresAt;
    }

    public function setExpiresAt(?\DateTimeInterface $expiresAt): static
    {
        $this->expiresAt = $expiresAt;
        return $this;
    }

    #[Groups(['tradelisting:read'])]
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

    #[Groups(['tradelisting:read'])]
    public function getCardId(): ?int
    {
        return $this->card?->getId();
    }

    public function getCard(): ?Card
    {
        return $this->card;
    }

    public function setCard(?Card $card): static
    {
        $this->card = $card;
        return $this;
    }

    #[Groups(['tradelisting:read'])]
    public function getBidsId(): ?int
    {
        return $this->bids?->getId();
    }

    public function getBids(): ?TradeBid
    {
        return $this->bids;
    }

    public function setBids(?TradeBid $bids): static
    {
        $this->bids = $bids;
        return $this;
    }

}
