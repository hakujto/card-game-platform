<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Players\AchievementRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;

#[ORM\Entity(repositoryClass: AchievementRepository::class)]
#[ORM\Table(name: 'achievement')]
class Achievement
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['achievement:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['achievement:read', 'achievement:write'])]
    private string $name = '';

    #[ORM\Column(type: 'text')]
    #[Groups(['achievement:read', 'achievement:write'])]
    private string $description = '';

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['achievement:read', 'achievement:write'])]
    private ?string $iconUrl = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['achievement:read', 'achievement:write'])]
    private int $points = 10;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['achievement:read', 'achievement:write'])]
    private string $rarity = 'Common';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['achievement:read', 'achievement:write'])]
    private bool $isHidden = false;

    #[ORM\OneToMany(mappedBy: 'achievement', targetEntity: PlayerAchievement::class)]
    private Collection $playerRecords;

    public function __construct()
    {
        $this->playerRecords = new ArrayCollection();
    }

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

    public function getDescription(): string
    {
        return $this->description;
    }

    public function setDescription(string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getIconUrl(): ?string
    {
        return $this->iconUrl;
    }

    public function setIconUrl(?string $iconUrl): static
    {
        $this->iconUrl = $iconUrl;
        return $this;
    }

    public function getPoints(): int
    {
        return $this->points;
    }

    public function setPoints(int $points): static
    {
        $this->points = $points;
        return $this;
    }

    public function getRarity(): string
    {
        return $this->rarity;
    }

    public function setRarity(string $rarity): static
    {
        $this->rarity = $rarity;
        return $this;
    }

    public function getIsHidden(): bool
    {
        return $this->isHidden;
    }

    public function setIsHidden(bool $isHidden): static
    {
        $this->isHidden = $isHidden;
        return $this;
    }

    public function getPlayerRecords(): Collection
    {
        return $this->playerRecords;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Achievement must award at least one point")]
    public function isPointsPositiveValid(): bool
    {
        return ($this->getPoints() === null || $this->getPoints() > 0);
    }

    // ── Business operations ──────────────────────────────────────────

    public function pointValue($multiplier): mixed
    {
        // TODO: implement point_value
        return null;
    }

    public function reveal(): void
    {
        // TODO: implement reveal
    }

}
