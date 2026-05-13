<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\DraftPickRepository;
use App\Entity\Cards\Card;

#[ORM\Entity(repositoryClass: DraftPickRepository::class)]
#[ORM\Table(name: 'draft_pick')]
class DraftPick
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['draftPick:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['draftPick:read', 'draftPick:write'])]
    private int $pickNumber = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['draftPick:read', 'draftPick:write'])]
    private int $packNumber = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['draftPick:read', 'draftPick:write'])]
    private ?\DateTimeInterface $pickedAt = null;

    #[ORM\ManyToOne(targetEntity: DraftParticipant::class, inversedBy: 'picks')]
    #[ORM\JoinColumn(nullable: false)]
    private ?DraftParticipant $participant = null;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'draft_picks')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $card = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getPickNumber(): int
    {
        return $this->pickNumber;
    }

    public function setPickNumber(int $pickNumber): static
    {
        $this->pickNumber = $pickNumber;
        return $this;
    }

    public function getPackNumber(): int
    {
        return $this->packNumber;
    }

    public function setPackNumber(int $packNumber): static
    {
        $this->packNumber = $packNumber;
        return $this;
    }

    public function getPickedAt(): ?\DateTimeInterface
    {
        return $this->pickedAt;
    }

    public function setPickedAt(?\DateTimeInterface $pickedAt): static
    {
        $this->pickedAt = $pickedAt;
        return $this;
    }

    #[Groups(['draftPick:read'])]
    public function getParticipantId(): ?int
    {
        return $this->participant?->getId();
    }

    public function getParticipant(): ?DraftParticipant
    {
        return $this->participant;
    }

    public function setParticipant(?DraftParticipant $participant): static
    {
        $this->participant = $participant;
        return $this;
    }

    #[Groups(['draftPick:read'])]
    public function getCardId(): ?int
    {
        return $this->card?->getId();
    }

    public function getCard(): ?Card
    {
        return $this->card;
    }

    public function setCard(?Card $card): static
    {
        $this->card = $card;
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function isFirstPick(): void
    {
        throw new \RuntimeException('is_first_pick not implemented');
    }

}
