<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\MatchRecordRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: MatchRecordRepository::class)]
#[ORM\Table(name: 'match_record')]
class MatchRecord
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['matchRecord:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['matchRecord:read', 'matchRecord:write'])]
    private ?int $tableNumber = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['matchRecord:read', 'matchRecord:write'])]
    private string $status = 'Pending';

    #[ORM\Column(type: 'integer')]
    #[Groups(['matchRecord:read', 'matchRecord:write'])]
    private int $player1Wins = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['matchRecord:read', 'matchRecord:write'])]
    private int $player2Wins = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['matchRecord:read', 'matchRecord:write'])]
    private ?\DateTimeInterface $startedAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['matchRecord:read', 'matchRecord:write'])]
    private ?\DateTimeInterface $endedAt = null;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['matchRecord:read', 'matchRecord:write'])]
    private ?string $resultNotes = null;

    #[ORM\ManyToOne(targetEntity: TournamentRound::class, inversedBy: 'matches')]
    #[ORM\JoinColumn(nullable: true)]
    private ?TournamentRound $round = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'matches_as_player1')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player1 = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'matches_as_player2')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Player $player2 = null;

    #[ORM\ManyToOne(targetEntity: Game::class, inversedBy: 'match')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Game $games = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getTableNumber(): ?int
    {
        return $this->tableNumber;
    }

    public function setTableNumber(?int $tableNumber): static
    {
        $this->tableNumber = $tableNumber;
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

    public function getPlayer1Wins(): int
    {
        return $this->player1Wins;
    }

    public function setPlayer1Wins(int $player1Wins): static
    {
        $this->player1Wins = $player1Wins;
        return $this;
    }

    public function getPlayer2Wins(): int
    {
        return $this->player2Wins;
    }

    public function setPlayer2Wins(int $player2Wins): static
    {
        $this->player2Wins = $player2Wins;
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

    public function getResultNotes(): ?string
    {
        return $this->resultNotes;
    }

    public function setResultNotes(?string $resultNotes): static
    {
        $this->resultNotes = $resultNotes;
        return $this;
    }

    #[Groups(['matchRecord:read'])]
    public function getRoundId(): ?int
    {
        return $this->round?->getId();
    }

    public function getRound(): ?TournamentRound
    {
        return $this->round;
    }

    public function setRound(?TournamentRound $round): static
    {
        $this->round = $round;
        return $this;
    }

    #[Groups(['matchRecord:read'])]
    public function getPlayer1Id(): ?int
    {
        return $this->player1?->getId();
    }

    public function getPlayer1(): ?Player
    {
        return $this->player1;
    }

    public function setPlayer1(?Player $player1): static
    {
        $this->player1 = $player1;
        return $this;
    }

    #[Groups(['matchRecord:read'])]
    public function getPlayer2Id(): ?int
    {
        return $this->player2?->getId();
    }

    public function getPlayer2(): ?Player
    {
        return $this->player2;
    }

    public function setPlayer2(?Player $player2): static
    {
        $this->player2 = $player2;
        return $this;
    }

    #[Groups(['matchRecord:read'])]
    public function getGamesId(): ?int
    {
        return $this->games?->getId();
    }

    public function getGames(): ?Game
    {
        return $this->games;
    }

    public function setGames(?Game $games): static
    {
        $this->games = $games;
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function recordResult($p1Wins, $p2Wins): void
    {
        throw new \RuntimeException('record_result not implemented');
    }

    public function determineWinner(): void
    {
        throw new \RuntimeException('determine_winner not implemented');
    }

    public function draw(): void
    {
        throw new \RuntimeException('draw not implemented');
    }

}
