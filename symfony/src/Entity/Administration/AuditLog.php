<?php

namespace App\Entity\Administration;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Administration\AuditLogRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: AuditLogRepository::class)]
#[ORM\Table(name: 'audit_log')]
class AuditLog
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['auditLog:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['auditLog:read', 'auditLog:write'])]
    private string $action = '';

    #[ORM\Column(type: 'string', length: 100)]
    #[Groups(['auditLog:read', 'auditLog:write'])]
    private string $targetType = '';

    #[ORM\Column(type: 'string', length: 100)]
    #[Groups(['auditLog:read', 'auditLog:write'])]
    private string $targetId = '';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['auditLog:read', 'auditLog:write'])]
    private ?string $oldValue = null;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['auditLog:read', 'auditLog:write'])]
    private ?string $newValue = null;

    #[ORM\Column(type: 'string', length: 45, nullable: true)]
    #[Groups(['auditLog:read', 'auditLog:write'])]
    private ?string $ipAddress = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['auditLog:read', 'auditLog:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'audit_logs')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $admin = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getAction(): string
    {
        return $this->action;
    }

    public function setAction(string $action): static
    {
        $this->action = $action;
        return $this;
    }

    public function getTargetType(): string
    {
        return $this->targetType;
    }

    public function setTargetType(string $targetType): static
    {
        $this->targetType = $targetType;
        return $this;
    }

    public function getTargetId(): string
    {
        return $this->targetId;
    }

    public function setTargetId(string $targetId): static
    {
        $this->targetId = $targetId;
        return $this;
    }

    public function getOldValue(): ?string
    {
        return $this->oldValue;
    }

    public function setOldValue(?string $oldValue): static
    {
        $this->oldValue = $oldValue;
        return $this;
    }

    public function getNewValue(): ?string
    {
        return $this->newValue;
    }

    public function setNewValue(?string $newValue): static
    {
        $this->newValue = $newValue;
        return $this;
    }

    public function getIpAddress(): ?string
    {
        return $this->ipAddress;
    }

    public function setIpAddress(?string $ipAddress): static
    {
        $this->ipAddress = $ipAddress;
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

    #[Groups(['auditLog:read'])]
    public function getAdminId(): ?int
    {
        return $this->admin?->getId();
    }

    public function getAdmin(): ?Player
    {
        return $this->admin;
    }

    public function setAdmin(?Player $admin): static
    {
        $this->admin = $admin;
        return $this;
    }

}
