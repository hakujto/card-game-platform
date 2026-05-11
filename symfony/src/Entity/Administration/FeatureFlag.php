<?php

namespace App\Entity\Administration;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Administration\FeatureFlagRepository;

#[ORM\Entity(repositoryClass: FeatureFlagRepository::class)]
#[ORM\Table(name: 'feature_flag')]
class FeatureFlag
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['featureFlag:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 100)]
    #[Groups(['featureFlag:read', 'featureFlag:write'])]
    private string $key = '';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['featureFlag:read', 'featureFlag:write'])]
    private bool $isEnabled = false;

    #[ORM\Column(type: 'integer')]
    #[Groups(['featureFlag:read', 'featureFlag:write'])]
    private int $rolloutPercent = 100;

    #[ORM\Column(type: 'string', length: 300, nullable: true)]
    #[Groups(['featureFlag:read', 'featureFlag:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['featureFlag:read', 'featureFlag:write'])]
    private ?\DateTimeInterface $updatedAt = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getKey(): string
    {
        return $this->key;
    }

    public function setKey(string $key): static
    {
        $this->key = $key;
        return $this;
    }

    public function getIsEnabled(): bool
    {
        return $this->isEnabled;
    }

    public function setIsEnabled(bool $isEnabled): static
    {
        $this->isEnabled = $isEnabled;
        return $this;
    }

    public function getRolloutPercent(): int
    {
        return $this->rolloutPercent;
    }

    public function setRolloutPercent(int $rolloutPercent): static
    {
        $this->rolloutPercent = $rolloutPercent;
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

}
