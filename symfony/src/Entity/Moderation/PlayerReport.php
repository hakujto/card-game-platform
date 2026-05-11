<?php

namespace App\Entity\Moderation;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Moderation\PlayerReportRepository;
use App\Entity\Players\Player;
use App\Entity\Tournaments\MatchRecord;

#[ORM\Entity(repositoryClass: PlayerReportRepository::class)]
#[ORM\Table(name: 'player_report')]
class PlayerReport
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['playerReport:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['playerReport:read', 'playerReport:write'])]
    private string $reason = '';

    #[ORM\Column(type: 'text')]
    #[Groups(['playerReport:read', 'playerReport:write'])]
    private string $description = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['playerReport:read', 'playerReport:write'])]
    private string $status = 'Open';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['playerReport:read', 'playerReport:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['playerReport:read', 'playerReport:write'])]
    private ?\DateTimeInterface $reviewedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'reports_received')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $reportedPlayer = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'reports_submitted')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $reporter = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'reports_reviewed')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Player $reviewedBy = null;

    #[ORM\ManyToOne(targetEntity: MatchRecord::class, inversedBy: 'reports')]
    #[ORM\JoinColumn(nullable: true)]
    private ?MatchRecord $match = null;

    public function getId(): ?int
    {
        return $this->id;
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

    public function getDescription(): string
    {
        return $this->description;
    }

    public function setDescription(string $description): static
    {
        $this->description = $description;
        return $this;
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

    public function getCreatedAt(): ?\DateTimeInterface
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?\DateTimeInterface $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getReviewedAt(): ?\DateTimeInterface
    {
        return $this->reviewedAt;
    }

    public function setReviewedAt(?\DateTimeInterface $reviewedAt): static
    {
        $this->reviewedAt = $reviewedAt;
        return $this;
    }

    #[Groups(['playerReport:read'])]
    public function getReportedPlayerId(): ?int
    {
        return $this->reportedPlayer?->getId();
    }

    public function getReportedPlayer(): ?Player
    {
        return $this->reportedPlayer;
    }

    public function setReportedPlayer(?Player $reportedPlayer): static
    {
        $this->reportedPlayer = $reportedPlayer;
        return $this;
    }

    #[Groups(['playerReport:read'])]
    public function getReporterId(): ?int
    {
        return $this->reporter?->getId();
    }

    public function getReporter(): ?Player
    {
        return $this->reporter;
    }

    public function setReporter(?Player $reporter): static
    {
        $this->reporter = $reporter;
        return $this;
    }

    #[Groups(['playerReport:read'])]
    public function getReviewedById(): ?int
    {
        return $this->reviewedBy?->getId();
    }

    public function getReviewedBy(): ?Player
    {
        return $this->reviewedBy;
    }

    public function setReviewedBy(?Player $reviewedBy): static
    {
        $this->reviewedBy = $reviewedBy;
        return $this;
    }

    #[Groups(['playerReport:read'])]
    public function getMatchId(): ?int
    {
        return $this->match?->getId();
    }

    public function getMatch(): ?MatchRecord
    {
        return $this->match;
    }

    public function setMatch(?MatchRecord $match): static
    {
        $this->match = $match;
        return $this;
    }

}
