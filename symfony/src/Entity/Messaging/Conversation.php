<?php

namespace App\Entity\Messaging;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Messaging\ConversationRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: ConversationRepository::class)]
#[ORM\Table(name: 'conversation')]
class Conversation
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['conversation:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['conversation:read', 'conversation:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['conversation:read', 'conversation:write'])]
    private ?\DateTimeInterface $lastMessageAt = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['conversation:read', 'conversation:write'])]
    private bool $isArchivedByPlayer1 = false;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['conversation:read', 'conversation:write'])]
    private bool $isArchivedByPlayer2 = false;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'conversations_as_p1')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player1 = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'conversations_as_p2')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player2 = null;

    #[ORM\ManyToOne(targetEntity: Message::class, inversedBy: 'conversation')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Message $messages = null;

    public function getId(): ?int
    {
        return $this->id;
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

    public function getLastMessageAt(): ?\DateTimeInterface
    {
        return $this->lastMessageAt;
    }

    public function setLastMessageAt(?\DateTimeInterface $lastMessageAt): static
    {
        $this->lastMessageAt = $lastMessageAt;
        return $this;
    }

    public function getIsArchivedByPlayer1(): bool
    {
        return $this->isArchivedByPlayer1;
    }

    public function setIsArchivedByPlayer1(bool $isArchivedByPlayer1): static
    {
        $this->isArchivedByPlayer1 = $isArchivedByPlayer1;
        return $this;
    }

    public function getIsArchivedByPlayer2(): bool
    {
        return $this->isArchivedByPlayer2;
    }

    public function setIsArchivedByPlayer2(bool $isArchivedByPlayer2): static
    {
        $this->isArchivedByPlayer2 = $isArchivedByPlayer2;
        return $this;
    }

    #[Groups(['conversation:read'])]
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

    #[Groups(['conversation:read'])]
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

    #[Groups(['conversation:read'])]
    public function getMessagesId(): ?int
    {
        return $this->messages?->getId();
    }

    public function getMessages(): ?Message
    {
        return $this->messages;
    }

    public function setMessages(?Message $messages): static
    {
        $this->messages = $messages;
        return $this;
    }

}
