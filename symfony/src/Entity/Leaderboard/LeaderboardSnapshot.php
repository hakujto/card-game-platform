<?php

namespace App\Entity\Leaderboard;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Leaderboard\LeaderboardSnapshotRepository;

#[ORM\Entity(repositoryClass: LeaderboardSnapshotRepository::class)]
#[ORM\Table(name: 'leaderboard_snapshot')]
class LeaderboardSnapshot
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['leaderboardSnapshot:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'date', nullable: true)]
    #[Groups(['leaderboardSnapshot:read', 'leaderboardSnapshot:write'])]
    private ?\DateTimeInterface $snapshotDate = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardSnapshot:read', 'leaderboardSnapshot:write'])]
    private int $position = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardSnapshot:read', 'leaderboardSnapshot:write'])]
    private int $rating = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardSnapshot:read', 'leaderboardSnapshot:write'])]
    private int $seasonPoints = 0;

    #[ORM\ManyToOne(targetEntity: LeaderboardEntry::class, inversedBy: 'snapshots')]
    #[ORM\JoinColumn(nullable: false)]
    private ?LeaderboardEntry $entry = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getSnapshotDate(): ?\DateTimeInterface
    {
        return $this->snapshotDate;
    }

    public function setSnapshotDate(?\DateTimeInterface $snapshotDate): static
    {
        $this->snapshotDate = $snapshotDate;
        return $this;
    }

    public function getPosition(): int
    {
        return $this->position;
    }

    public function setPosition(int $position): static
    {
        $this->position = $position;
        return $this;
    }

    public function getRating(): int
    {
        return $this->rating;
    }

    public function setRating(int $rating): static
    {
        $this->rating = $rating;
        return $this;
    }

    public function getSeasonPoints(): int
    {
        return $this->seasonPoints;
    }

    public function setSeasonPoints(int $seasonPoints): static
    {
        $this->seasonPoints = $seasonPoints;
        return $this;
    }

    #[Groups(['leaderboardSnapshot:read'])]
    public function getEntryId(): ?int
    {
        return $this->entry?->getId();
    }

    public function getEntry(): ?LeaderboardEntry
    {
        return $this->entry;
    }

    public function setEntry(?LeaderboardEntry $entry): static
    {
        $this->entry = $entry;
        return $this;
    }

}
