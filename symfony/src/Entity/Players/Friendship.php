<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Players\FriendshipRepository;

#[ORM\Entity(repositoryClass: FriendshipRepository::class)]
#[ORM\Table(name: 'friendship')]
class Friendship
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['friendship:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['friendship:read', 'friendship:write'])]
    private string $status = 'Pending';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['friendship:read', 'friendship:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'sent_friend_requests')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $requester = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'received_friend_requests')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $receiver = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getStatus(): string
    {
        return $this->status;
    }

    public function setStatus(string $status): static
    {
        $this->status = $status;
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

    #[Groups(['friendship:read'])]
    public function getRequesterId(): ?int
    {
        return $this->requester?->getId();
    }

    public function getRequester(): ?Player
    {
        return $this->requester;
    }

    public function setRequester(?Player $requester): static
    {
        $this->requester = $requester;
        return $this;
    }

    #[Groups(['friendship:read'])]
    public function getReceiverId(): ?int
    {
        return $this->receiver?->getId();
    }

    public function getReceiver(): ?Player
    {
        return $this->receiver;
    }

    public function setReceiver(?Player $receiver): static
    {
        $this->receiver = $receiver;
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function accept(): void
    {
        throw new \RuntimeException('accept not implemented');
    }

    public function decline(): void
    {
        throw new \RuntimeException('decline not implemented');
    }

    public function block(): void
    {
        throw new \RuntimeException('block not implemented');
    }

}
