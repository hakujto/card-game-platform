<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Players\PlayerAchievementRepository;

#[ORM\Entity(repositoryClass: PlayerAchievementRepository::class)]
#[ORM\Table(name: 'player_achievement')]
class PlayerAchievement
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['playerAchievement:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['playerAchievement:read', 'playerAchievement:write'])]
    private ?\DateTimeInterface $earnedAt = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['playerAchievement:read', 'playerAchievement:write'])]
    private int $progress = 0;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['playerAchievement:read', 'playerAchievement:write'])]
    private bool $isCompleted = false;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'achievement_records')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: Achievement::class, inversedBy: 'player_records')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Achievement $achievement = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getEarnedAt(): ?\DateTimeInterface
    {
        return $this->earnedAt;
    }

    public function setEarnedAt(?\DateTimeInterface $earnedAt): static
    {
        $this->earnedAt = $earnedAt;
        return $this;
    }

    public function getProgress(): int
    {
        return $this->progress;
    }

    public function setProgress(int $progress): static
    {
        $this->progress = $progress;
        return $this;
    }

    public function getIsCompleted(): bool
    {
        return $this->isCompleted;
    }

    public function setIsCompleted(bool $isCompleted): static
    {
        $this->isCompleted = $isCompleted;
        return $this;
    }

    #[Groups(['playerAchievement:read'])]
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

    #[Groups(['playerAchievement:read'])]
    public function getAchievementId(): ?int
    {
        return $this->achievement?->getId();
    }

    public function getAchievement(): ?Achievement
    {
        return $this->achievement;
    }

    public function setAchievement(?Achievement $achievement): static
    {
        $this->achievement = $achievement;
        return $this;
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getIsCompleted() === true && !(($this->getProgress() === null || $this->getProgress() > 0))) {
            throw new \DomainException('Completed achievement must have progress greater than zero');
        }
    }

}
