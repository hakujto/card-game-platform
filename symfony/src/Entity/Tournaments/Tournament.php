<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\TournamentRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: TournamentRepository::class)]
#[ORM\Table(name: 'tournament')]
class Tournament
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tournament:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private string $name = '';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private string $format = 'Standard';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private string $tournamentType = 'Swiss';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private string $status = 'Draft';

    #[ORM\Column(type: 'integer')]
    #[Groups(['tournament:read', 'tournament:write'])]
    private int $maxPlayers = 0;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private string $entryFee = '0.00';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private string $prizePool = '0.00';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private ?\DateTimeInterface $startTime = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private ?\DateTimeInterface $endTime = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['tournament:read', 'tournament:write'])]
    private bool $isOnline = true;

    #[ORM\Column(type: 'string', length: 300, nullable: true)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private ?string $location = null;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private ?string $rulesText = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['tournament:read', 'tournament:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Season::class, inversedBy: 'tournaments')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Season $season = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'organized_tournaments')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $organizer = null;

    #[ORM\ManyToOne(targetEntity: TournamentRegistration::class, inversedBy: 'tournament')]
    #[ORM\JoinColumn(nullable: true)]
    private ?TournamentRegistration $registrations = null;

    #[ORM\ManyToOne(targetEntity: TournamentRound::class, inversedBy: 'tournament')]
    #[ORM\JoinColumn(nullable: true)]
    private ?TournamentRound $rounds = null;

    #[ORM\ManyToOne(targetEntity: TournamentPrize::class, inversedBy: 'tournament')]
    #[ORM\JoinColumn(nullable: true)]
    private ?TournamentPrize $prizes = null;

    #[ORM\ManyToMany(targetEntity: Player::class)]
    #[ORM\JoinTable(name: 'tournament_judges_m2m')]
    private Collection $judges;

    public function __construct()
    {
        $this->judges = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getFormat(): string
    {
        return $this->format;
    }

    public function setFormat(string $format): static
    {
        $this->format = $format;
        return $this;
    }

    public function getTournamentType(): string
    {
        return $this->tournamentType;
    }

    public function setTournamentType(string $tournamentType): static
    {
        $this->tournamentType = $tournamentType;
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

    public function getMaxPlayers(): int
    {
        return $this->maxPlayers;
    }

    public function setMaxPlayers(int $maxPlayers): static
    {
        $this->maxPlayers = $maxPlayers;
        return $this;
    }

    public function getEntryFee(): string
    {
        return $this->entryFee;
    }

    public function setEntryFee(string $entryFee): static
    {
        $this->entryFee = $entryFee;
        return $this;
    }

    public function getPrizePool(): string
    {
        return $this->prizePool;
    }

    public function setPrizePool(string $prizePool): static
    {
        $this->prizePool = $prizePool;
        return $this;
    }

    public function getStartTime(): ?\DateTimeInterface
    {
        return $this->startTime;
    }

    public function setStartTime(?\DateTimeInterface $startTime): static
    {
        $this->startTime = $startTime;
        return $this;
    }

    public function getEndTime(): ?\DateTimeInterface
    {
        return $this->endTime;
    }

    public function setEndTime(?\DateTimeInterface $endTime): static
    {
        $this->endTime = $endTime;
        return $this;
    }

    public function getIsOnline(): bool
    {
        return $this->isOnline;
    }

    public function setIsOnline(bool $isOnline): static
    {
        $this->isOnline = $isOnline;
        return $this;
    }

    public function getLocation(): ?string
    {
        return $this->location;
    }

    public function setLocation(?string $location): static
    {
        $this->location = $location;
        return $this;
    }

    public function getRulesText(): ?string
    {
        return $this->rulesText;
    }

    public function setRulesText(?string $rulesText): static
    {
        $this->rulesText = $rulesText;
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

    #[Groups(['tournament:read'])]
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

    #[Groups(['tournament:read'])]
    public function getOrganizerId(): ?int
    {
        return $this->organizer?->getId();
    }

    public function getOrganizer(): ?Player
    {
        return $this->organizer;
    }

    public function setOrganizer(?Player $organizer): static
    {
        $this->organizer = $organizer;
        return $this;
    }

    #[Groups(['tournament:read'])]
    public function getRegistrationsId(): ?int
    {
        return $this->registrations?->getId();
    }

    public function getRegistrations(): ?TournamentRegistration
    {
        return $this->registrations;
    }

    public function setRegistrations(?TournamentRegistration $registrations): static
    {
        $this->registrations = $registrations;
        return $this;
    }

    #[Groups(['tournament:read'])]
    public function getRoundsId(): ?int
    {
        return $this->rounds?->getId();
    }

    public function getRounds(): ?TournamentRound
    {
        return $this->rounds;
    }

    public function setRounds(?TournamentRound $rounds): static
    {
        $this->rounds = $rounds;
        return $this;
    }

    #[Groups(['tournament:read'])]
    public function getPrizesId(): ?int
    {
        return $this->prizes?->getId();
    }

    public function getPrizes(): ?TournamentPrize
    {
        return $this->prizes;
    }

    public function setPrizes(?TournamentPrize $prizes): static
    {
        $this->prizes = $prizes;
        return $this;
    }

    public function getJudges(): Collection
    {
        return $this->judges;
    }

    public function addJudges(Player $item): static
    {
        if (!$this->judges->contains($item)) {
            $this->judges->add($item);
        }
        return $this;
    }

    public function removeJudges(Player $item): static
    {
        $this->judges->removeElement($item);
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function start(): void
    {
        throw new \RuntimeException('start not implemented');
    }

    public function cancel(): void
    {
        throw new \RuntimeException('cancel not implemented');
    }

    public function complete(): void
    {
        throw new \RuntimeException('complete not implemented');
    }

    public function generateRound(): void
    {
        throw new \RuntimeException('generate_round not implemented');
    }

    public function calculatePrizeDistribution(): void
    {
        throw new \RuntimeException('calculate_prize_distribution not implemented');
    }

    public function isFull(): void
    {
        throw new \RuntimeException('is_full not implemented');
    }

}
