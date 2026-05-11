<?php

namespace App\Entity\Notifications;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Notifications\PushDeviceRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: PushDeviceRepository::class)]
#[ORM\Table(name: 'push_device')]
class PushDevice
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['pushDevice:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 500)]
    #[Groups(['pushDevice:read', 'pushDevice:write'])]
    private string $deviceToken = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['pushDevice:read', 'pushDevice:write'])]
    private string $platform = 'Web';

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['pushDevice:read', 'pushDevice:write'])]
    private ?string $deviceName = null;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['pushDevice:read', 'pushDevice:write'])]
    private bool $isActive = true;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['pushDevice:read', 'pushDevice:write'])]
    private ?\DateTimeInterface $registeredAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['pushDevice:read', 'pushDevice:write'])]
    private ?\DateTimeInterface $lastUsedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'push_devices')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getDeviceToken(): string
    {
        return $this->deviceToken;
    }

    public function setDeviceToken(string $deviceToken): static
    {
        $this->deviceToken = $deviceToken;
        return $this;
    }

    public function getPlatform(): string
    {
        return $this->platform;
    }

    public function setPlatform(string $platform): static
    {
        $this->platform = $platform;
        return $this;
    }

    public function getDeviceName(): ?string
    {
        return $this->deviceName;
    }

    public function setDeviceName(?string $deviceName): static
    {
        $this->deviceName = $deviceName;
        return $this;
    }

    public function getIsActive(): bool
    {
        return $this->isActive;
    }

    public function setIsActive(bool $isActive): static
    {
        $this->isActive = $isActive;
        return $this;
    }

    public function getRegisteredAt(): ?\DateTimeInterface
    {
        return $this->registeredAt;
    }

    public function setRegisteredAt(?\DateTimeInterface $registeredAt): static
    {
        $this->registeredAt = $registeredAt;
        return $this;
    }

    public function getLastUsedAt(): ?\DateTimeInterface
    {
        return $this->lastUsedAt;
    }

    public function setLastUsedAt(?\DateTimeInterface $lastUsedAt): static
    {
        $this->lastUsedAt = $lastUsedAt;
        return $this;
    }

    #[Groups(['pushDevice:read'])]
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
