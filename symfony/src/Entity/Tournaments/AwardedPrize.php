<?php

namespace App\Entity\Tournaments;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Tournaments\AwardedPrizeRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: AwardedPrizeRepository::class)]
#[ORM\Table(name: 'awarded_prize')]
class AwardedPrize
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['awardedPrize:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['awardedPrize:read', 'awardedPrize:write'])]
    private int $finalPlacement = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['awardedPrize:read', 'awardedPrize:write'])]
    private ?\DateTimeInterface $awardedAt = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['awardedPrize:read', 'awardedPrize:write'])]
    private bool $claimed = false;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['awardedPrize:read', 'awardedPrize:write'])]
    private ?\DateTimeInterface $claimedAt = null;

    #[ORM\ManyToOne(targetEntity: TournamentPrize::class, inversedBy: 'awarded_prizes')]
    #[ORM\JoinColumn(nullable: false)]
    private ?TournamentPrize $prize = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'awarded_prizes')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getFinalPlacement(): int
    {
        return $this->finalPlacement;
    }

    public function setFinalPlacement(int $finalPlacement): static
    {
        $this->finalPlacement = $finalPlacement;
        return $this;
    }

    public function getAwardedAt(): ?\DateTimeInterface
    {
        return $this->awardedAt;
    }

    public function setAwardedAt(?\DateTimeInterface $awardedAt): static
    {
        $this->awardedAt = $awardedAt;
        return $this;
    }

    public function getClaimed(): bool
    {
        return $this->claimed;
    }

    public function setClaimed(bool $claimed): static
    {
        $this->claimed = $claimed;
        return $this;
    }

    public function getClaimedAt(): ?\DateTimeInterface
    {
        return $this->claimedAt;
    }

    public function setClaimedAt(?\DateTimeInterface $claimedAt): static
    {
        $this->claimedAt = $claimedAt;
        return $this;
    }

    #[Groups(['awardedPrize:read'])]
    public function getPrizeId(): ?int
    {
        return $this->prize?->getId();
    }

    public function getPrize(): ?TournamentPrize
    {
        return $this->prize;
    }

    public function setPrize(?TournamentPrize $prize): static
    {
        $this->prize = $prize;
        return $this;
    }

    #[Groups(['awardedPrize:read'])]
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

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Final placement must be greater than zero")]
    public function isFinalPlacementPositiveValid(): bool
    {
        return ($this->getFinalPlacement() === null || $this->getFinalPlacement() > 0);
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getClaimed() === true && $this->getClaimedAt() === null) {
            throw new \DomainException('Claimed prize must have a claimed_at timestamp');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function claim(): void
    {
        throw new \RuntimeException('claim not implemented');
    }

}
