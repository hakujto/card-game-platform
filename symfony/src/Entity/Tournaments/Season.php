<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\SeasonRepository;

#[ORM\Entity(repositoryClass: SeasonRepository::class)]
#[ORM\Table(name: 'season')]
class Season
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['season:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['season:read', 'season:write'])]
    private string $name = '';

    #[ORM\Column(type: 'date', nullable: true)]
    #[Groups(['season:read', 'season:write'])]
    private ?\DateTimeInterface $startDate = null;

    #[ORM\Column(type: 'date', nullable: true)]
    #[Groups(['season:read', 'season:write'])]
    private ?\DateTimeInterface $endDate = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['season:read', 'season:write'])]
    private string $format = 'Standard';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['season:read', 'season:write'])]
    private bool $isActive = false;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['season:read', 'season:write'])]
    private ?string $rewardDescription = null;

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

    public function getStartDate(): ?\DateTimeInterface
    {
        return $this->startDate;
    }

    public function setStartDate(?\DateTimeInterface $startDate): static
    {
        $this->startDate = $startDate;
        return $this;
    }

    public function getEndDate(): ?\DateTimeInterface
    {
        return $this->endDate;
    }

    public function setEndDate(?\DateTimeInterface $endDate): static
    {
        $this->endDate = $endDate;
        return $this;
    }

    public function getFormat(): string
    {
        return $this->format;
    }

    public function setFormat(string $format): static
    {
        $this->format = $format;
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

    public function getRewardDescription(): ?string
    {
        return $this->rewardDescription;
    }

    public function setRewardDescription(?string $rewardDescription): static
    {
        $this->rewardDescription = $rewardDescription;
        return $this;
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

    public function finalizeRewards(): void
    {
        throw new \RuntimeException('finalize_rewards not implemented');
    }

    public function isOngoing(): void
    {
        throw new \RuntimeException('is_ongoing not implemented');
    }

}
