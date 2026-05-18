<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\ProductRepository;
use App\Entity\Cards\Card;
use App\Entity\Cards\CardSet;

#[ORM\Entity(repositoryClass: ProductRepository::class)]
#[ORM\Table(name: 'product')]
class Product
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['product:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['product:read', 'product:write'])]
    private string $name = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['product:read', 'product:write'])]
    private string $productType = 'SingleCard';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['product:read', 'product:write'])]
    private string $price = '0.00';

    #[ORM\Column(type: 'integer')]
    #[Groups(['product:read', 'product:write'])]
    private int $stock = 0;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['product:read', 'product:write'])]
    private bool $active = true;

    #[ORM\Column(type: 'integer')]
    #[Groups(['product:read', 'product:write'])]
    private int $discountPercent = 0;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['product:read', 'product:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['product:read', 'product:write'])]
    private ?string $imageUrl = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['product:read', 'product:write'])]
    private bool $featured = false;

    #[ORM\OneToOne(targetEntity: Card::class)]
    #[ORM\JoinColumn(nullable: true)]
    private ?Card $card = null;

    #[ORM\ManyToOne(targetEntity: CardSet::class, inversedBy: 'shop_products')]
    #[ORM\JoinColumn(nullable: true)]
    private ?CardSet $cardSet = null;

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

    public function getProductType(): string
    {
        return $this->productType;
    }

    public function setProductType(string $productType): static
    {
        $this->productType = $productType;
        return $this;
    }

    public function getPrice(): string
    {
        return $this->price;
    }

    public function setPrice(string $price): static
    {
        $this->price = $price;
        return $this;
    }

    public function getStock(): int
    {
        return $this->stock;
    }

    public function setStock(int $stock): static
    {
        $this->stock = $stock;
        return $this;
    }

    public function getActive(): bool
    {
        return $this->active;
    }

    public function setActive(bool $active): static
    {
        $this->active = $active;
        return $this;
    }

    public function getDiscountPercent(): int
    {
        return $this->discountPercent;
    }

    public function setDiscountPercent(int $discountPercent): static
    {
        $this->discountPercent = $discountPercent;
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

    public function getImageUrl(): ?string
    {
        return $this->imageUrl;
    }

    public function setImageUrl(?string $imageUrl): static
    {
        $this->imageUrl = $imageUrl;
        return $this;
    }

    public function getFeatured(): bool
    {
        return $this->featured;
    }

    public function setFeatured(bool $featured): static
    {
        $this->featured = $featured;
        return $this;
    }

    #[Groups(['product:read'])]
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

    #[Groups(['product:read'])]
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
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Product price must be greater than zero")]
    public function isPricePositiveValid(): bool
    {
        return ($this->getPrice() === null || (float)$this->getPrice() > (float)0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Product stock must not be negative")]
    public function isStockNotNegativeValid(): bool
    {
        return ($this->getStock() === null || $this->getStock() >= 0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Product discount percent must be between 0 and 100")]
    public function isDiscountPercentRangeValid(): bool
    {
        return ($this->getDiscountPercent() === null || ($this->getDiscountPercent() >= 0 && $this->getDiscountPercent() <= 100));
    }

    // ── Business operations ──────────────────────────────────────────

    public function activate(): void
    {
        throw new \RuntimeException('activate not implemented');
    }

    public function deactivate(): void
    {
        throw new \RuntimeException('deactivate not implemented');
    }

    public function applyDiscount($percent): void
    {
        throw new \RuntimeException('apply_discount not implemented');
    }

    public function restock($quantity): void
    {
        throw new \RuntimeException('restock not implemented');
    }

    public function effectivePrice(): void
    {
        throw new \RuntimeException('effective_price not implemented');
    }

    public function isInStock(): void
    {
        throw new \RuntimeException('is_in_stock not implemented');
    }

}
