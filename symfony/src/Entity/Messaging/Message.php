<?php

namespace App\Entity\Messaging;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Messaging\MessageRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: MessageRepository::class)]
#[ORM\Table(name: 'message')]
class Message
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['message:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'text')]
    #[Groups(['message:read', 'message:write'])]
    private string $body = '';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['message:read', 'message:write'])]
    private bool $isRead = false;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['message:read', 'message:write'])]
    private ?\DateTimeInterface $readAt = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['message:read', 'message:write'])]
    private bool $isDeletedBySender = false;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['message:read', 'message:write'])]
    private bool $isDeletedByReceiver = false;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['message:read', 'message:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Conversation::class, inversedBy: 'messages')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Conversation $conversation = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'sent_messages')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $sender = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getBody(): string
    {
        return $this->body;
    }

    public function setBody(string $body): static
    {
        $this->body = $body;
        return $this;
    }

    public function getIsRead(): bool
    {
        return $this->isRead;
    }

    public function setIsRead(bool $isRead): static
    {
        $this->isRead = $isRead;
        return $this;
    }

    public function getReadAt(): ?\DateTimeInterface
    {
        return $this->readAt;
    }

    public function setReadAt(?\DateTimeInterface $readAt): static
    {
        $this->readAt = $readAt;
        return $this;
    }

    public function getIsDeletedBySender(): bool
    {
        return $this->isDeletedBySender;
    }

    public function setIsDeletedBySender(bool $isDeletedBySender): static
    {
        $this->isDeletedBySender = $isDeletedBySender;
        return $this;
    }

    public function getIsDeletedByReceiver(): bool
    {
        return $this->isDeletedByReceiver;
    }

    public function setIsDeletedByReceiver(bool $isDeletedByReceiver): static
    {
        $this->isDeletedByReceiver = $isDeletedByReceiver;
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

    #[Groups(['message:read'])]
    public function getConversationId(): ?int
    {
        return $this->conversation?->getId();
    }

    public function getConversation(): ?Conversation
    {
        return $this->conversation;
    }

    public function setConversation(?Conversation $conversation): static
    {
        $this->conversation = $conversation;
        return $this;
    }

    #[Groups(['message:read'])]
    public function getSenderId(): ?int
    {
        return $this->sender?->getId();
    }

    public function getSender(): ?Player
    {
        return $this->sender;
    }

    public function setSender(?Player $sender): static
    {
        $this->sender = $sender;
        return $this;
    }

}
