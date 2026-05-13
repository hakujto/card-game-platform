<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\DraftParticipantRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: DraftParticipantRepository::class)]
#[ORM\Table(name: 'draft_participant')]
class DraftParticipant
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['draftParticipant:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['draftParticipant:read', 'draftParticipant:write'])]
    private int $seatNumber = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['draftParticipant:read', 'draftParticipant:write'])]
    private ?\DateTimeInterface $joinedAt = null;

    #[ORM\ManyToOne(targetEntity: DraftSession::class, inversedBy: 'participants')]
    #[ORM\JoinColumn(nullable: true)]
    private ?DraftSession $session = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'draft_sessions')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: DraftPick::class, inversedBy: 'participant')]
    #[ORM\JoinColumn(nullable: true)]
    private ?DraftPick $draftedCards = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getSeatNumber(): int
    {
        return $this->seatNumber;
    }

    public function setSeatNumber(int $seatNumber): static
    {
        $this->seatNumber = $seatNumber;
        return $this;
    }

    public function getJoinedAt(): ?\DateTimeInterface
    {
        return $this->joinedAt;
    }

    public function setJoinedAt(?\DateTimeInterface $joinedAt): static
    {
        $this->joinedAt = $joinedAt;
        return $this;
    }

    #[Groups(['draftParticipant:read'])]
    public function getSessionId(): ?int
    {
        return $this->session?->getId();
    }

    public function getSession(): ?DraftSession
    {
        return $this->session;
    }

    public function setSession(?DraftSession $session): static
    {
        $this->session = $session;
        return $this;
    }

    #[Groups(['draftParticipant:read'])]
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

    #[Groups(['draftParticipant:read'])]
    public function getDraftedCardsId(): ?int
    {
        return $this->draftedCards?->getId();
    }

    public function getDraftedCards(): ?DraftPick
    {
        return $this->draftedCards;
    }

    public function setDraftedCards(?DraftPick $draftedCards): static
    {
        $this->draftedCards = $draftedCards;
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function pickCard($cardId, $packNumber): void
    {
        throw new \RuntimeException('pick_card not implemented');
    }

    public function draftedCardCount(): void
    {
        throw new \RuntimeException('drafted_card_count not implemented');
    }

}
