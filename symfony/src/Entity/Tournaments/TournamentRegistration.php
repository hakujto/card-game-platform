<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\TournamentRegistrationRepository;
use App\Entity\Players\Player;
use App\Entity\Cards\Deck;

#[ORM\Entity(repositoryClass: TournamentRegistrationRepository::class)]
#[ORM\Table(name: 'tournament_registration')]
class TournamentRegistration
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tournamentRegistration:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tournamentRegistration:read', 'tournamentRegistration:write'])]
    private string $status = 'Registered';

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['tournamentRegistration:read', 'tournamentRegistration:write'])]
    private ?int $seed = null;

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['tournamentRegistration:read', 'tournamentRegistration:write'])]
    private ?int $finalStanding = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['tournamentRegistration:read', 'tournamentRegistration:write'])]
    private int $pointsEarned = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tournamentRegistration:read', 'tournamentRegistration:write'])]
    private ?\DateTimeInterface $registeredAt = null;

    #[ORM\ManyToOne(targetEntity: Tournament::class, inversedBy: 'registrations')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Tournament $tournament = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'tournament_registrations')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: Deck::class, inversedBy: 'tournament_registrations')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Deck $deck = null;

    public function getId(): ?int
    {
        return $this->id;
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

    public function getSeed(): ?int
    {
        return $this->seed;
    }

    public function setSeed(?int $seed): static
    {
        $this->seed = $seed;
        return $this;
    }

    public function getFinalStanding(): ?int
    {
        return $this->finalStanding;
    }

    public function setFinalStanding(?int $finalStanding): static
    {
        $this->finalStanding = $finalStanding;
        return $this;
    }

    public function getPointsEarned(): int
    {
        return $this->pointsEarned;
    }

    public function setPointsEarned(int $pointsEarned): static
    {
        $this->pointsEarned = $pointsEarned;
        return $this;
    }

    public function getRegisteredAt(): ?\DateTimeInterface
    {
        return $this->registeredAt;
    }

    public function setRegisteredAt(?\DateTimeInterface $registeredAt): static
    {
        $this->registeredAt = $registeredAt;
        return $this;
    }

    #[Groups(['tournamentRegistration:read'])]
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

    #[Groups(['tournamentRegistration:read'])]
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

    #[Groups(['tournamentRegistration:read'])]
    public function getDeckId(): ?int
    {
        return $this->deck?->getId();
    }

    public function getDeck(): ?Deck
    {
        return $this->deck;
    }

    public function setDeck(?Deck $deck): static
    {
        $this->deck = $deck;
        return $this;
    }

}
