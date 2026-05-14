<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\GameRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: GameRepository::class)]
#[ORM\Table(name: 'game')]
class Game
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['game:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['game:read', 'game:write'])]
    private int $gameNumber = 0;

    #[ORM\Column(type: 'string', length: 20, nullable: true)]
    #[Groups(['game:read', 'game:write'])]
    private ?string $winnerSide = null;

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['game:read', 'game:write'])]
    private ?int $turnsPlayed = null;

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['game:read', 'game:write'])]
    private ?int $durationSeconds = null;

    #[ORM\Column(type: 'string', length: 20, nullable: true)]
    #[Groups(['game:read', 'game:write'])]
    private ?string $endedBy = null;

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['game:read', 'game:write'])]
    private ?string $replayUrl = null;

    #[ORM\ManyToOne(targetEntity: MatchRecord::class, inversedBy: 'games')]
    #[ORM\JoinColumn(nullable: false)]
    private ?MatchRecord $match = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'won_games')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Player $winner = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getGameNumber(): int
    {
        return $this->gameNumber;
    }

    public function setGameNumber(int $gameNumber): static
    {
        $this->gameNumber = $gameNumber;
        return $this;
    }

    public function getWinnerSide(): ?string
    {
        return $this->winnerSide;
    }

    public function setWinnerSide(?string $winnerSide): static
    {
        $this->winnerSide = $winnerSide;
        return $this;
    }

    public function getTurnsPlayed(): ?int
    {
        return $this->turnsPlayed;
    }

    public function setTurnsPlayed(?int $turnsPlayed): static
    {
        $this->turnsPlayed = $turnsPlayed;
        return $this;
    }

    public function getDurationSeconds(): ?int
    {
        return $this->durationSeconds;
    }

    public function setDurationSeconds(?int $durationSeconds): static
    {
        $this->durationSeconds = $durationSeconds;
        return $this;
    }

    public function getEndedBy(): ?string
    {
        return $this->endedBy;
    }

    public function setEndedBy(?string $endedBy): static
    {
        $this->endedBy = $endedBy;
        return $this;
    }

    public function getReplayUrl(): ?string
    {
        return $this->replayUrl;
    }

    public function setReplayUrl(?string $replayUrl): static
    {
        $this->replayUrl = $replayUrl;
        return $this;
    }

    #[Groups(['game:read'])]
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

    #[Groups(['game:read'])]
    public function getWinnerId(): ?int
    {
        return $this->winner?->getId();
    }

    public function getWinner(): ?Player
    {
        return $this->winner;
    }

    public function setWinner(?Player $winner): static
    {
        $this->winner = $winner;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Game number must be between 1 and 3 (best-of-3)")]
    public function isGameNumberRangeValid(): bool
    {
        return ($this->getGameNumber() === null || ($this->getGameNumber() >= 1 && $this->getGameNumber() <= 3));
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getTurnsPlayed() !== null && !(($this->getTurnsPlayed() === null || $this->getTurnsPlayed() > 0))) {
            throw new \DomainException('Turns played must be greater than zero');
        }
        if ($this->getDurationSeconds() !== null && !(($this->getDurationSeconds() === null || $this->getDurationSeconds() > 0))) {
            throw new \DomainException('Game duration must be greater than zero');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function recordWinner($winnerSide): void
    {
        throw new \RuntimeException('record_winner not implemented');
    }

    public function durationMinutes(): void
    {
        throw new \RuntimeException('duration_minutes not implemented');
    }

}
