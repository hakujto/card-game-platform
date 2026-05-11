<?php

namespace App\Entity\Economy;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Economy\TopUpPackageRepository;

#[ORM\Entity(repositoryClass: TopUpPackageRepository::class)]
#[ORM\Table(name: 'top_up_package')]
class TopUpPackage
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['topUpPackage:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['topUpPackage:read', 'topUpPackage:write'])]
    private string $name = '';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['topUpPackage:read', 'topUpPackage:write'])]
    private string $price = '0.00';

    #[ORM\Column(type: 'string', length: 3)]
    #[Groups(['topUpPackage:read', 'topUpPackage:write'])]
    private string $currency = 'USD';

    #[ORM\Column(type: 'decimal', precision: 12, scale: 2)]
    #[Groups(['topUpPackage:read', 'topUpPackage:write'])]
    private string $creditsAmount = '0.00';

    #[ORM\Column(type: 'integer')]
    #[Groups(['topUpPackage:read', 'topUpPackage:write'])]
    private int $gemsAmount = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['topUpPackage:read', 'topUpPackage:write'])]
    private int $bonusPercent = 0;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['topUpPackage:read', 'topUpPackage:write'])]
    private bool $isActive = true;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['topUpPackage:read', 'topUpPackage:write'])]
    private bool $featured = false;

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

    public function getPrice(): string
    {
        return $this->price;
    }

    public function setPrice(string $price): static
    {
        $this->price = $price;
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

    public function getCreditsAmount(): string
    {
        return $this->creditsAmount;
    }

    public function setCreditsAmount(string $creditsAmount): static
    {
        $this->creditsAmount = $creditsAmount;
        return $this;
    }

    public function getGemsAmount(): int
    {
        return $this->gemsAmount;
    }

    public function setGemsAmount(int $gemsAmount): static
    {
        $this->gemsAmount = $gemsAmount;
        return $this;
    }

    public function getBonusPercent(): int
    {
        return $this->bonusPercent;
    }

    public function setBonusPercent(int $bonusPercent): static
    {
        $this->bonusPercent = $bonusPercent;
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

    public function getFeatured(): bool
    {
        return $this->featured;
    }

    public function setFeatured(bool $featured): static
    {
        $this->featured = $featured;
        return $this;
    }

}
