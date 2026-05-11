<?php

namespace App\Entity\Administration;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Administration\PlatformConfigRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: PlatformConfigRepository::class)]
#[ORM\Table(name: 'platform_config')]
class PlatformConfig
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['platformConfig:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 100)]
    #[Groups(['platformConfig:read', 'platformConfig:write'])]
    private string $configKey = '';

    #[ORM\Column(type: 'string', length: 500)]
    #[Groups(['platformConfig:read', 'platformConfig:write'])]
    private string $configValue = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['platformConfig:read', 'platformConfig:write'])]
    private string $valueType = 'String';

    #[ORM\Column(type: 'string', length: 300, nullable: true)]
    #[Groups(['platformConfig:read', 'platformConfig:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['platformConfig:read', 'platformConfig:write'])]
    private ?\DateTimeInterface $updatedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'config_changes')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $updatedBy = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getConfigKey(): string
    {
        return $this->configKey;
    }

    public function setConfigKey(string $configKey): static
    {
        $this->configKey = $configKey;
        return $this;
    }

    public function getConfigValue(): string
    {
        return $this->configValue;
    }

    public function setConfigValue(string $configValue): static
    {
        $this->configValue = $configValue;
        return $this;
    }

    public function getValueType(): string
    {
        return $this->valueType;
    }

    public function setValueType(string $valueType): static
    {
        $this->valueType = $valueType;
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

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeInterface $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    #[Groups(['platformConfig:read'])]
    public function getUpdatedById(): ?int
    {
        return $this->updatedBy?->getId();
    }

    public function getUpdatedBy(): ?Player
    {
        return $this->updatedBy;
    }

    public function setUpdatedBy(?Player $updatedBy): static
    {
        $this->updatedBy = $updatedBy;
        return $this;
    }

}
