<?php

namespace App\Entity\Moderation;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Moderation\ModerationActionRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: ModerationActionRepository::class)]
#[ORM\Table(name: 'moderation_action')]
class ModerationAction
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['moderationAction:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['moderationAction:read', 'moderationAction:write'])]
    private string $actionType = '';

    #[ORM\Column(type: 'text')]
    #[Groups(['moderationAction:read', 'moderationAction:write'])]
    private string $reason = '';

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['moderationAction:read', 'moderationAction:write'])]
    private ?int $durationDays = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['moderationAction:read', 'moderationAction:write'])]
    private ?\DateTimeInterface $expiresAt = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['moderationAction:read', 'moderationAction:write'])]
    private bool $isActive = true;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['moderationAction:read', 'moderationAction:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['moderationAction:read', 'moderationAction:write'])]
    private ?\DateTimeInterface $revokedAt = null;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['moderationAction:read', 'moderationAction:write'])]
    private ?string $revokeReason = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'moderation_actions')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'issued_actions')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $moderator = null;

    #[ORM\ManyToOne(targetEntity: PlayerReport::class, inversedBy: 'action')]
    #[ORM\JoinColumn(nullable: true)]
    private ?PlayerReport $report = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getActionType(): string
    {
        return $this->actionType;
    }

    public function setActionType(string $actionType): static
    {
        $this->actionType = $actionType;
        return $this;
    }

    public function getReason(): string
    {
        return $this->reason;
    }

    public function setReason(string $reason): static
    {
        $this->reason = $reason;
        return $this;
    }

    public function getDurationDays(): ?int
    {
        return $this->durationDays;
    }

    public function setDurationDays(?int $durationDays): static
    {
        $this->durationDays = $durationDays;
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

    public function getIsActive(): bool
    {
        return $this->isActive;
    }

    public function setIsActive(bool $isActive): static
    {
        $this->isActive = $isActive;
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

    public function getRevokedAt(): ?\DateTimeInterface
    {
        return $this->revokedAt;
    }

    public function setRevokedAt(?\DateTimeInterface $revokedAt): static
    {
        $this->revokedAt = $revokedAt;
        return $this;
    }

    public function getRevokeReason(): ?string
    {
        return $this->revokeReason;
    }

    public function setRevokeReason(?string $revokeReason): static
    {
        $this->revokeReason = $revokeReason;
        return $this;
    }

    #[Groups(['moderationAction:read'])]
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

    #[Groups(['moderationAction:read'])]
    public function getModeratorId(): ?int
    {
        return $this->moderator?->getId();
    }

    public function getModerator(): ?Player
    {
        return $this->moderator;
    }

    public function setModerator(?Player $moderator): static
    {
        $this->moderator = $moderator;
        return $this;
    }

    #[Groups(['moderationAction:read'])]
    public function getReportId(): ?int
    {
        return $this->report?->getId();
    }

    public function getReport(): ?PlayerReport
    {
        return $this->report;
    }

    public function setReport(?PlayerReport $report): static
    {
        $this->report = $report;
        return $this;
    }

}
