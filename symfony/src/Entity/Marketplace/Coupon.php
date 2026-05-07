<?php

namespace App\Entity\Marketplace;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Marketplace\CouponRepository;

#[ORM\Entity(repositoryClass: CouponRepository::class)]
#[ORM\Table(name: 'coupon')]
class Coupon
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['coupon:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 50)]
    #[Groups(['coupon:read', 'coupon:write'])]
    private string $code = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['coupon:read', 'coupon:write'])]
    private string $discountType = 'Percent';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['coupon:read', 'coupon:write'])]
    private string $discountValue = '0.00';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['coupon:read', 'coupon:write'])]
    private string $minOrderValue = '0.00';

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['coupon:read', 'coupon:write'])]
    private ?int $maxUses = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['coupon:read', 'coupon:write'])]
    private int $usesCount = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['coupon:read', 'coupon:write'])]
    private ?\DateTimeInterface $validFrom = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['coupon:read', 'coupon:write'])]
    private ?\DateTimeInterface $validUntil = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['coupon:read', 'coupon:write'])]
    private bool $isActive = true;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCode(): string
    {
        return $this->code;
    }

    public function setCode(string $code): static
    {
        $this->code = $code;
        return $this;
    }

    public function getDiscountType(): string
    {
        return $this->discountType;
    }

    public function setDiscountType(string $discountType): static
    {
        $this->discountType = $discountType;
        return $this;
    }

    public function getDiscountValue(): string
    {
        return $this->discountValue;
    }

    public function setDiscountValue(string $discountValue): static
    {
        $this->discountValue = $discountValue;
        return $this;
    }

    public function getMinOrderValue(): string
    {
        return $this->minOrderValue;
    }

    public function setMinOrderValue(string $minOrderValue): static
    {
        $this->minOrderValue = $minOrderValue;
        return $this;
    }

    public function getMaxUses(): ?int
    {
        return $this->maxUses;
    }

    public function setMaxUses(?int $maxUses): static
    {
        $this->maxUses = $maxUses;
        return $this;
    }

    public function getUsesCount(): int
    {
        return $this->usesCount;
    }

    public function setUsesCount(int $usesCount): static
    {
        $this->usesCount = $usesCount;
        return $this;
    }

    public function getValidFrom(): ?\DateTimeInterface
    {
        return $this->validFrom;
    }

    public function setValidFrom(?\DateTimeInterface $validFrom): static
    {
        $this->validFrom = $validFrom;
        return $this;
    }

    public function getValidUntil(): ?\DateTimeInterface
    {
        return $this->validUntil;
    }

    public function setValidUntil(?\DateTimeInterface $validUntil): static
    {
        $this->validUntil = $validUntil;
        return $this;
    }

    public function getIsActive(): bool
    {
        return $this->isActive;
    }

    public function setIsActive(bool $isActive): static
    {
        $this->isActive = $isActive;
        return $this;
    }

}
