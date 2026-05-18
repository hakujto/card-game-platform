<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\TournamentRoundRepository;

#[ORM\Entity(repositoryClass: TournamentRoundRepository::class)]
#[ORM\Table(name: 'tournament_round')]
class TournamentRound
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tournamentRound:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['tournamentRound:read', 'tournamentRound:write'])]
    private int $roundNumber = 0;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tournamentRound:read', 'tournamentRound:write'])]
    private string $status = 'Pending';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tournamentRound:read', 'tournamentRound:write'])]
    private ?\DateTimeInterface $startedAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tournamentRound:read', 'tournamentRound:write'])]
    private ?\DateTimeInterface $endedAt = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['tournamentRound:read', 'tournamentRound:write'])]
    private int $timeLimitMinutes = 50;

    #[ORM\ManyToOne(targetEntity: Tournament::class, inversedBy: 'rounds')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Tournament $tournament = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getRoundNumber(): int
    {
        return $this->roundNumber;
    }

    public function setRoundNumber(int $roundNumber): static
    {
        $this->roundNumber = $roundNumber;
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

    public function getStartedAt(): ?\DateTimeInterface
    {
        return $this->startedAt;
    }

    public function setStartedAt(?\DateTimeInterface $startedAt): static
    {
        $this->startedAt = $startedAt;
        return $this;
    }

    public function getEndedAt(): ?\DateTimeInterface
    {
        return $this->endedAt;
    }

    public function setEndedAt(?\DateTimeInterface $endedAt): static
    {
        $this->endedAt = $endedAt;
        return $this;
    }

    public function getTimeLimitMinutes(): int
    {
        return $this->timeLimitMinutes;
    }

    public function setTimeLimitMinutes(int $timeLimitMinutes): static
    {
        $this->timeLimitMinutes = $timeLimitMinutes;
        return $this;
    }

    #[Groups(['tournamentRound:read'])]
    public function getTournamentId(): ?int
    {
        return $this->tournament?->getId();
    }

    public function getTournament(): ?Tournament
    {
        return $this->tournament;
    }

    public function setTournament(?Tournament $tournament): static
    {
        $this->tournament = $tournament;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Round number must be greater than zero")]
    public function isRoundNumberPositiveValid(): bool
    {
        return ($this->getRoundNumber() === null || $this->getRoundNumber() > 0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Round time limit must be greater than zero")]
    public function isTimeLimitPositiveValid(): bool
    {
        return ($this->getTimeLimitMinutes() === null || $this->getTimeLimitMinutes() > 0);
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getEndedAt() !== null && !(($this->getEndedAt() === null || ($this->getStartedAt() !== null && $this->getEndedAt() > $this->getStartedAt())))) {
            throw new \DomainException('Round end time must be after start time');
        }
        if ($this->getStatus() === 'COMPLETED' && $this->getStartedAt() === null) {
            throw new \DomainException('Completed round must have a start time');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function start(): void
    {
        throw new \RuntimeException('start not implemented');
    }

    public function complete(): void
    {
        throw new \RuntimeException('complete not implemented');
    }

    public function generatePairings(): void
    {
        throw new \RuntimeException('generate_pairings not implemented');
    }

    public function isTimeExpired(): void
    {
        throw new \RuntimeException('is_time_expired not implemented');
    }

}
