<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\TournamentPrizeRepository;
use Symfony\Component\Validator\Constraints as Assert;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;

#[ORM\Entity(repositoryClass: TournamentPrizeRepository::class)]
#[ORM\Table(name: 'tournament_prize')]
class TournamentPrize
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['tournamentPrize:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['tournamentPrize:read', 'tournamentPrize:write'])]
    #[Assert\Range(min: 1)]
    private int $placementFrom = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['tournamentPrize:read', 'tournamentPrize:write'])]
    #[Assert\Range(min: 1)]
    private int $placementTo = 0;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['tournamentPrize:read', 'tournamentPrize:write'])]
    private string $prizeType = '';

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['tournamentPrize:read', 'tournamentPrize:write'])]
    private string $amount = '0.00';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['tournamentPrize:read', 'tournamentPrize:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['tournamentPrize:read', 'tournamentPrize:write'])]
    private ?int $packsCount = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['tournamentPrize:read', 'tournamentPrize:write'])]
    private int $seasonPoints = 0;

    #[ORM\ManyToOne(targetEntity: Tournament::class, inversedBy: 'prizes')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'CASCADE')]
    private ?Tournament $tournament = null;

    #[ORM\OneToMany(mappedBy: 'prize', targetEntity: AwardedPrize::class)]
    private Collection $awardedPrizes;

    public function __construct()
    {
        $this->awardedPrizes = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getPlacementFrom(): int
    {
        return $this->placementFrom;
    }

    public function setPlacementFrom(int $placementFrom): static
    {
        $this->placementFrom = $placementFrom;
        return $this;
    }

    public function getPlacementTo(): int
    {
        return $this->placementTo;
    }

    public function setPlacementTo(int $placementTo): static
    {
        $this->placementTo = $placementTo;
        return $this;
    }

    public function getPrizeType(): string
    {
        return $this->prizeType;
    }

    public function setPrizeType(string $prizeType): static
    {
        $this->prizeType = $prizeType;
        return $this;
    }

    public function getAmount(): string
    {
        return $this->amount;
    }

    public function setAmount(string $amount): static
    {
        $this->amount = $amount;
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

    public function getPacksCount(): ?int
    {
        return $this->packsCount;
    }

    public function setPacksCount(?int $packsCount): static
    {
        $this->packsCount = $packsCount;
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

    #[Groups(['tournamentPrize:read'])]
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

    public function getAwardedPrizes(): Collection
    {
        return $this->awardedPrizes;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "placement_to must be greater than or equal to placement_from")]
    public function isPlacementRangeValidValid(): bool
    {
        return ($this->getPlacementTo() === null || ($this->getPlacementFrom() !== null && $this->getPlacementTo() >= $this->getPlacementFrom()));
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "placement_from must be greater than zero")]
    public function isPlacementFromPositiveValid(): bool
    {
        return ($this->getPlacementFrom() === null || $this->getPlacementFrom() > 0);
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Prize amount must not be negative")]
    public function isAmountNotNegativeValid(): bool
    {
        return ($this->getAmount() === null || (float)$this->getAmount() >= (float)0);
    }

    // ── Business operations ──────────────────────────────────────────

    public function appliesToPlacement($placement): mixed
    {
        // TODO: implement applies_to_placement
        return null;
    }

    public function awardToPlayer($playerId): void
    {
        // TODO: implement award_to_player
    }

}
