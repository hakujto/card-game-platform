<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\OrderRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: OrderRepository::class)]
#[ORM\Table(name: '`order`')]
class Order
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['order:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['order:read', 'order:write'])]
    private string $status = 'Pending';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['order:read', 'order:write'])]
    private string $total = '0.00';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['order:read', 'order:write'])]
    private string $discountApplied = '0.00';

    #[ORM\Column(type: 'string', length: 3)]
    #[Groups(['order:read', 'order:write'])]
    private string $currency = 'USD';

    #[ORM\Column(type: 'string', length: 20, nullable: true)]
    #[Groups(['order:read', 'order:write'])]
    private ?string $paymentMethod = null;

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['order:read', 'order:write'])]
    private ?string $paymentReference = null;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['order:read', 'order:write'])]
    private ?string $shippingAddress = null;

    #[ORM\Column(type: 'string', length: 100, nullable: true)]
    #[Groups(['order:read', 'order:write'])]
    private ?string $trackingNumber = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['order:read', 'order:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['order:read', 'order:write'])]
    private ?\DateTimeInterface $paidAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['order:read', 'order:write'])]
    private ?\DateTimeInterface $shippedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'orders')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: Coupon::class, inversedBy: 'orders')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Coupon $coupon = null;

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

    public function getTotal(): string
    {
        return $this->total;
    }

    public function setTotal(string $total): static
    {
        $this->total = $total;
        return $this;
    }

    public function getDiscountApplied(): string
    {
        return $this->discountApplied;
    }

    public function setDiscountApplied(string $discountApplied): static
    {
        $this->discountApplied = $discountApplied;
        return $this;
    }

    public function getCurrency(): string
    {
        return $this->currency;
    }

    public function setCurrency(string $currency): static
    {
        $this->currency = $currency;
        return $this;
    }

    public function getPaymentMethod(): ?string
    {
        return $this->paymentMethod;
    }

    public function setPaymentMethod(?string $paymentMethod): static
    {
        $this->paymentMethod = $paymentMethod;
        return $this;
    }

    public function getPaymentReference(): ?string
    {
        return $this->paymentReference;
    }

    public function setPaymentReference(?string $paymentReference): static
    {
        $this->paymentReference = $paymentReference;
        return $this;
    }

    public function getShippingAddress(): ?string
    {
        return $this->shippingAddress;
    }

    public function setShippingAddress(?string $shippingAddress): static
    {
        $this->shippingAddress = $shippingAddress;
        return $this;
    }

    public function getTrackingNumber(): ?string
    {
        return $this->trackingNumber;
    }

    public function setTrackingNumber(?string $trackingNumber): static
    {
        $this->trackingNumber = $trackingNumber;
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

    public function getPaidAt(): ?\DateTimeInterface
    {
        return $this->paidAt;
    }

    public function setPaidAt(?\DateTimeInterface $paidAt): static
    {
        $this->paidAt = $paidAt;
        return $this;
    }

    public function getShippedAt(): ?\DateTimeInterface
    {
        return $this->shippedAt;
    }

    public function setShippedAt(?\DateTimeInterface $shippedAt): static
    {
        $this->shippedAt = $shippedAt;
        return $this;
    }

    #[Groups(['order:read'])]
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

    #[Groups(['order:read'])]
    public function getCouponId(): ?int
    {
        return $this->coupon?->getId();
    }

    public function getCoupon(): ?Coupon
    {
        return $this->coupon;
    }

    public function setCoupon(?Coupon $coupon): static
    {
        $this->coupon = $coupon;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Order total must not be negative")]
    public function isTotalNotNegativeValid(): bool
    {
        return ($this->getTotal() === null || (float)$this->getTotal() >= (float)0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Discount applied cannot exceed order total")]
    public function isDiscountNotExceedTotalValid(): bool
    {
        return ($this->getDiscountApplied() === null || ($this->getTotal() !== null && (float)$this->getDiscountApplied() <= (float)$this->getTotal()));
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getStatus() === 'PAID' && $this->getPaidAt() === null) {
            throw new \DomainException('Paid order must have paid_at set');
        }
        if ($this->getStatus() === 'SHIPPED' && $this->getTrackingNumber() === null) {
            throw new \DomainException('Shipped order must have a tracking number');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function cancel(): void
    {
        throw new \RuntimeException('cancel not implemented');
    }

    public function pay($paymentRef): void
    {
        throw new \RuntimeException('pay not implemented');
    }

    public function calculateTotal(): void
    {
        throw new \RuntimeException('calculate_total not implemented');
    }

    public function applyDiscount($percent): void
    {
        throw new \RuntimeException('apply_discount not implemented');
    }

    public function refund(): void
    {
        throw new \RuntimeException('refund not implemented');
    }

    public function notifyShipped(): void
    {
        throw new \RuntimeException('notify_shipped not implemented');
    }

}
