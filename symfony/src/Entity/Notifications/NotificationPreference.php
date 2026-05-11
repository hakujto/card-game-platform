<?php

namespace App\Entity\Notifications;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Notifications\NotificationPreferenceRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: NotificationPreferenceRepository::class)]
#[ORM\Table(name: 'notification_preference')]
class NotificationPreference
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['notificationPreference:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['notificationPreference:read', 'notificationPreference:write'])]
    private string $notificationType = '';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['notificationPreference:read', 'notificationPreference:write'])]
    private bool $emailEnabled = true;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['notificationPreference:read', 'notificationPreference:write'])]
    private bool $pushEnabled = true;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['notificationPreference:read', 'notificationPreference:write'])]
    private bool $inAppEnabled = true;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'notification_preferences')]
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

    public function getEmailEnabled(): bool
    {
        return $this->emailEnabled;
    }

    public function setEmailEnabled(bool $emailEnabled): static
    {
        $this->emailEnabled = $emailEnabled;
        return $this;
    }

    public function getPushEnabled(): bool
    {
        return $this->pushEnabled;
    }

    public function setPushEnabled(bool $pushEnabled): static
    {
        $this->pushEnabled = $pushEnabled;
        return $this;
    }

    public function getInAppEnabled(): bool
    {
        return $this->inAppEnabled;
    }

    public function setInAppEnabled(bool $inAppEnabled): static
    {
        $this->inAppEnabled = $inAppEnabled;
        return $this;
    }

    #[Groups(['notificationPreference:read'])]
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
