<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\OrderItemRepository;

#[ORM\Entity(repositoryClass: OrderItemRepository::class)]
#[ORM\Table(name: 'order_item')]
class OrderItem
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['orderItem:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['orderItem:read', 'orderItem:write'])]
    private int $quantity = 0;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['orderItem:read', 'orderItem:write'])]
    private string $priceAtPurchase = '0.00';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['orderItem:read', 'orderItem:write'])]
    private bool $foil = false;

    #[ORM\ManyToOne(targetEntity: Order::class, inversedBy: 'items')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Order $order = null;

    #[ORM\ManyToOne(targetEntity: Product::class, inversedBy: 'order_items')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Product $product = null;

    public function getId(): ?int
    {
        return $this->id;
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

    public function getPriceAtPurchase(): string
    {
        return $this->priceAtPurchase;
    }

    public function setPriceAtPurchase(string $priceAtPurchase): static
    {
        $this->priceAtPurchase = $priceAtPurchase;
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

    #[Groups(['orderItem:read'])]
    public function getOrderId(): ?int
    {
        return $this->order?->getId();
    }

    public function getOrder(): ?Order
    {
        return $this->order;
    }

    public function setOrder(?Order $order): static
    {
        $this->order = $order;
        return $this;
    }

    #[Groups(['orderItem:read'])]
    public function getProductId(): ?int
    {
        return $this->product?->getId();
    }

    public function getProduct(): ?Product
    {
        return $this->product;
    }

    public function setProduct(?Product $product): static
    {
        $this->product = $product;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Order item quantity must be greater than zero")]
    public function isQuantityPositiveValid(): bool
    {
        return ($this->getQuantity() === null || $this->getQuantity() > 0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Price at purchase must not be negative")]
    public function isPriceNotNegativeValid(): bool
    {
        return ($this->getPriceAtPurchase() === null || (float)$this->getPriceAtPurchase() >= (float)0);
    }

    // ── Business operations ──────────────────────────────────────────

    public function lineTotal(): void
    {
        throw new \RuntimeException('line_total not implemented');
    }

}
