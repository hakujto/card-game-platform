<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Players\PlayerSeasonStatsRepository;
use App\Entity\Tournaments\Season;

#[ORM\Entity(repositoryClass: PlayerSeasonStatsRepository::class)]
#[ORM\Table(name: 'player_season_stats')]
class PlayerSeasonStats
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['playerSeasonStats:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['playerSeasonStats:read', 'playerSeasonStats:write'])]
    private int $wins = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['playerSeasonStats:read', 'playerSeasonStats:write'])]
    private int $losses = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['playerSeasonStats:read', 'playerSeasonStats:write'])]
    private int $draws = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['playerSeasonStats:read', 'playerSeasonStats:write'])]
    private int $tournamentWins = 0;

    #[ORM\Column(type: 'string', length: 20, nullable: true)]
    #[Groups(['playerSeasonStats:read', 'playerSeasonStats:write'])]
    private ?string $highestRank = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['playerSeasonStats:read', 'playerSeasonStats:write'])]
    private int $seasonPoints = 0;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'season_stats')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: Season::class, inversedBy: 'player_stats')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Season $season = null;

    public function getId(): ?int
    {
        return $this->id;
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

    public function getDraws(): int
    {
        return $this->draws;
    }

    public function setDraws(int $draws): static
    {
        $this->draws = $draws;
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

    public function getHighestRank(): ?string
    {
        return $this->highestRank;
    }

    public function setHighestRank(?string $highestRank): static
    {
        $this->highestRank = $highestRank;
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

    #[Groups(['playerSeasonStats:read'])]
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

    #[Groups(['playerSeasonStats:read'])]
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

    // ── Business operations ──────────────────────────────────────────

    public function winRate(): void
    {
        throw new \RuntimeException('win_rate not implemented');
    }

    public function addPoints($points): void
    {
        throw new \RuntimeException('add_points not implemented');
    }

    public function recordTournamentWin(): void
    {
        throw new \RuntimeException('record_tournament_win not implemented');
    }

}
