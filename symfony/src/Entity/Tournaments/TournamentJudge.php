<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\TournamentJudgeRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: TournamentJudgeRepository::class)]
#[ORM\Table(name: 'tournament_judge')]
class TournamentJudge
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tournamentJudge:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tournamentJudge:read', 'tournamentJudge:write'])]
    private string $role = 'Judge';

    #[ORM\ManyToOne(targetEntity: Tournament::class, inversedBy: 'judge_assignments')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Tournament $tournament = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'judge_roles')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getRole(): string
    {
        return $this->role;
    }

    public function setRole(string $role): static
    {
        $this->role = $role;
        return $this;
    }

    #[Groups(['tournamentJudge:read'])]
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

    #[Groups(['tournamentJudge:read'])]
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

    // ── Business operations ──────────────────────────────────────────

    public function promoteToHead(): void
    {
        throw new \RuntimeException('promote_to_head not implemented');
    }

    public function remove(): void
    {
        throw new \RuntimeException('remove not implemented');
    }

}
