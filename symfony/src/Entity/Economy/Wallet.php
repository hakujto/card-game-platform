<?php

namespace App\Entity\Economy;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Economy\WalletRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: WalletRepository::class)]
#[ORM\Table(name: 'wallet')]
class Wallet
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['wallet:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'decimal', precision: 12, scale: 2)]
    #[Groups(['wallet:read', 'wallet:write'])]
    private string $creditsBalance = '0.00';

    #[ORM\Column(type: 'integer')]
    #[Groups(['wallet:read', 'wallet:write'])]
    private int $dustBalance = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['wallet:read', 'wallet:write'])]
    private int $gemsBalance = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['wallet:read', 'wallet:write'])]
    private ?\DateTimeInterface $updatedAt = null;

    #[ORM\OneToOne(targetEntity: Player::class)]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getCreditsBalance(): string
    {
        return $this->creditsBalance;
    }

    public function setCreditsBalance(string $creditsBalance): static
    {
        $this->creditsBalance = $creditsBalance;
        return $this;
    }

    public function getDustBalance(): int
    {
        return $this->dustBalance;
    }

    public function setDustBalance(int $dustBalance): static
    {
        $this->dustBalance = $dustBalance;
        return $this;
    }

    public function getGemsBalance(): int
    {
        return $this->gemsBalance;
    }

    public function setGemsBalance(int $gemsBalance): static
    {
        $this->gemsBalance = $gemsBalance;
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

    #[Groups(['wallet:read'])]
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
