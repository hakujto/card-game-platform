<?php

namespace App\Entity\Administration;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Administration\SystemAnnouncementRepository;

#[ORM\Entity(repositoryClass: SystemAnnouncementRepository::class)]
#[ORM\Table(name: 'system_announcement')]
class SystemAnnouncement
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['systemAnnouncement:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 300)]
    #[Groups(['systemAnnouncement:read', 'systemAnnouncement:write'])]
    private string $title = '';

    #[ORM\Column(type: 'text')]
    #[Groups(['systemAnnouncement:read', 'systemAnnouncement:write'])]
    private string $body = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['systemAnnouncement:read', 'systemAnnouncement:write'])]
    private string $announcementType = 'Update';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['systemAnnouncement:read', 'systemAnnouncement:write'])]
    private string $severity = 'Info';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['systemAnnouncement:read', 'systemAnnouncement:write'])]
    private bool $isActive = true;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['systemAnnouncement:read', 'systemAnnouncement:write'])]
    private ?\DateTimeInterface $showFrom = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['systemAnnouncement:read', 'systemAnnouncement:write'])]
    private ?\DateTimeInterface $showUntil = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['systemAnnouncement:read', 'systemAnnouncement:write'])]
    private ?\DateTimeInterface $createdAt = null;

    public function getId(): ?int
    {
        return $this->id;
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

    public function getAnnouncementType(): string
    {
        return $this->announcementType;
    }

    public function setAnnouncementType(string $announcementType): static
    {
        $this->announcementType = $announcementType;
        return $this;
    }

    public function getSeverity(): string
    {
        return $this->severity;
    }

    public function setSeverity(string $severity): static
    {
        $this->severity = $severity;
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

    public function getShowFrom(): ?\DateTimeInterface
    {
        return $this->showFrom;
    }

    public function setShowFrom(?\DateTimeInterface $showFrom): static
    {
        $this->showFrom = $showFrom;
        return $this;
    }

    public function getShowUntil(): ?\DateTimeInterface
    {
        return $this->showUntil;
    }

    public function setShowUntil(?\DateTimeInterface $showUntil): static
    {
        $this->showUntil = $showUntil;
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

}
