<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\CardPriceHistoryRepository;
use App\Entity\Cards\Card;

#[ORM\Entity(repositoryClass: CardPriceHistoryRepository::class)]
#[ORM\Table(name: 'card_price_history')]
class CardPriceHistory
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['cardPriceHistory:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'date', nullable: true)]
    #[Groups(['cardPriceHistory:read', 'cardPriceHistory:write'])]
    private ?\DateTimeInterface $priceDate = null;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['cardPriceHistory:read', 'cardPriceHistory:write'])]
    private string $avgPrice = '0.00';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['cardPriceHistory:read', 'cardPriceHistory:write'])]
    private string $minPrice = '0.00';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['cardPriceHistory:read', 'cardPriceHistory:write'])]
    private string $maxPrice = '0.00';

    #[ORM\Column(type: 'integer')]
    #[Groups(['cardPriceHistory:read', 'cardPriceHistory:write'])]
    private int $volume = 0;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['cardPriceHistory:read', 'cardPriceHistory:write'])]
    private bool $foil = false;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'price_history')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $card = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getPriceDate(): ?\DateTimeInterface
    {
        return $this->priceDate;
    }

    public function setPriceDate(?\DateTimeInterface $priceDate): static
    {
        $this->priceDate = $priceDate;
        return $this;
    }

    public function getAvgPrice(): string
    {
        return $this->avgPrice;
    }

    public function setAvgPrice(string $avgPrice): static
    {
        $this->avgPrice = $avgPrice;
        return $this;
    }

    public function getMinPrice(): string
    {
        return $this->minPrice;
    }

    public function setMinPrice(string $minPrice): static
    {
        $this->minPrice = $minPrice;
        return $this;
    }

    public function getMaxPrice(): string
    {
        return $this->maxPrice;
    }

    public function setMaxPrice(string $maxPrice): static
    {
        $this->maxPrice = $maxPrice;
        return $this;
    }

    public function getVolume(): int
    {
        return $this->volume;
    }

    public function setVolume(int $volume): static
    {
        $this->volume = $volume;
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

    #[Groups(['cardPriceHistory:read'])]
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

    // ── Business operations ──────────────────────────────────────────

    public function priceChangePercent($previousAvg): void
    {
        throw new \RuntimeException('price_change_percent not implemented');
    }

    public function isPriceSpike($thresholdPercent): void
    {
        throw new \RuntimeException('is_price_spike not implemented');
    }

}
