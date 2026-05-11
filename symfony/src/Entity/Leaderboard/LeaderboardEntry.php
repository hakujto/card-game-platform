<?php

namespace App\Entity\Leaderboard;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Leaderboard\LeaderboardEntryRepository;
use App\Entity\Players\Player;
use App\Entity\Tournaments\Season;

#[ORM\Entity(repositoryClass: LeaderboardEntryRepository::class)]
#[ORM\Table(name: 'leaderboard_entry')]
class LeaderboardEntry
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['leaderboardEntry:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardEntry:read', 'leaderboardEntry:write'])]
    private int $position = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardEntry:read', 'leaderboardEntry:write'])]
    private int $rating = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardEntry:read', 'leaderboardEntry:write'])]
    private int $wins = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardEntry:read', 'leaderboardEntry:write'])]
    private int $losses = 0;

    #[ORM\Column(type: 'decimal', precision: 5, scale: 2)]
    #[Groups(['leaderboardEntry:read', 'leaderboardEntry:write'])]
    private string $winRate = '0.00';

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardEntry:read', 'leaderboardEntry:write'])]
    private int $tournamentWins = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['leaderboardEntry:read', 'leaderboardEntry:write'])]
    private int $seasonPoints = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['leaderboardEntry:read', 'leaderboardEntry:write'])]
    private ?\DateTimeInterface $updatedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'leaderboard_entries')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: Season::class, inversedBy: 'leaderboard_entries')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Season $season = null;

    public function getId(): ?int
    {
        return $this->id;
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

    public function getWins(): int
    {
        return $this->wins;
    }

    public function setWins(int $wins): static
    {
        $this->wins = $wins;
        return $this;
    }

    public function getLosses(): int
    {
        return $this->losses;
    }

    public function setLosses(int $losses): static
    {
        $this->losses = $losses;
        return $this;
    }

    public function getWinRate(): string
    {
        return $this->winRate;
    }

    public function setWinRate(string $winRate): static
    {
        $this->winRate = $winRate;
        return $this;
    }

    public function getTournamentWins(): int
    {
        return $this->tournamentWins;
    }

    public function setTournamentWins(int $tournamentWins): static
    {
        $this->tournamentWins = $tournamentWins;
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

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeInterface $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    #[Groups(['leaderboardEntry:read'])]
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

    #[Groups(['leaderboardEntry:read'])]
    public function getSeasonId(): ?int
    {
        return $this->season?->getId();
    }

    public function getSeason(): ?Season
    {
        return $this->season;
    }

    public function setSeason(?Season $season): static
    {
        $this->season = $season;
        return $this;
    }

}
