<?php

namespace App\Entity\Notifications;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Notifications\NotificationRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: NotificationRepository::class)]
#[ORM\Table(name: 'notification')]
class Notification
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['notification:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['notification:read', 'notification:write'])]
    private string $notificationType = '';

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['notification:read', 'notification:write'])]
    private string $title = '';

    #[ORM\Column(type: 'text')]
    #[Groups(['notification:read', 'notification:write'])]
    private string $body = '';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['notification:read', 'notification:write'])]
    private bool $isRead = false;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['notification:read', 'notification:write'])]
    private ?\DateTimeInterface $readAt = null;

    #[ORM\Column(type: 'string', length: 500, nullable: true)]
    #[Groups(['notification:read', 'notification:write'])]
    private ?string $actionUrl = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['notification:read', 'notification:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'notifications')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getNotificationType(): string
    {
        return $this->notificationType;
    }

    public function setNotificationType(string $notificationType): static
    {
        $this->notificationType = $notificationType;
        return $this;
    }

    public function getTitle(): string
    {
        return $this->title;
    }

    public function setTitle(string $title): static
    {
        $this->title = $title;
        return $this;
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

    public function getActionUrl(): ?string
    {
        return $this->actionUrl;
    }

    public function setActionUrl(?string $actionUrl): static
    {
        $this->actionUrl = $actionUrl;
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

    #[Groups(['notification:read'])]
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

}
