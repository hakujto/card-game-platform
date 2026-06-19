<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use Symfony\Component\Serializer\Annotation\SerializedName;
use App\Repository\Content\DraftParticipantRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
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
    #[SerializedName('joinedAt')]
    #[Groups(['draftParticipant:read', 'draftParticipant:write'])]
    private ?\DateTimeInterface $joinedAt = null;

    #[ORM\ManyToOne(targetEntity: DraftSession::class, inversedBy: 'participants')]
    #[ORM\JoinColumn(nullable: true, onDelete: 'CASCADE')]
    private ?DraftSession $session = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'draftSessions')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'RESTRICT')]
    private ?Player $player = null;

    #[ORM\OneToMany(mappedBy: 'participant', targetEntity: DraftPick::class)]
    private Collection $picks;

    public function __construct()
    {
        $this->picks = new ArrayCollection();
    }

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

    public function getPicks(): Collection
    {
        return $this->picks;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Seat number must be greater than zero")]
    public function isSeatNumberPositiveValid(): bool
    {
        return ($this->getSeatNumber() === null || $this->getSeatNumber() > 0);
    }

    // ── Business operations ──────────────────────────────────────────

    public function pickCard($cardId, $packNumber): void
    {
        // TODO: implement pick_card
    }

    public function draftedCardCount(): mixed
    {
        // TODO: implement drafted_card_count
        return null;
    }

}
