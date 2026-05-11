<?php

namespace App\Entity\Economy;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Economy\TopUpOrderRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: TopUpOrderRepository::class)]
#[ORM\Table(name: 'top_up_order')]
class TopUpOrder
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['topUpOrder:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'decimal', precision: 10, scale: 2)]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private string $amountPaid = '0.00';

    #[ORM\Column(type: 'string', length: 3)]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private string $currencyPaid = 'USD';

    #[ORM\Column(type: 'decimal', precision: 12, scale: 2)]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private string $creditsGranted = '0.00';

    #[ORM\Column(type: 'integer')]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private int $gemsGranted = 0;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private string $paymentMethod = 'Card';

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private ?string $paymentReference = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private string $status = 'Pending';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['topUpOrder:read', 'topUpOrder:write'])]
    private ?\DateTimeInterface $completedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'top_up_orders')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getAmountPaid(): string
    {
        return $this->amountPaid;
    }

    public function setAmountPaid(string $amountPaid): static
    {
        $this->amountPaid = $amountPaid;
        return $this;
    }

    public function getCurrencyPaid(): string
    {
        return $this->currencyPaid;
    }

    public function setCurrencyPaid(string $currencyPaid): static
    {
        $this->currencyPaid = $currencyPaid;
        return $this;
    }

    public function getCreditsGranted(): string
    {
        return $this->creditsGranted;
    }

    public function setCreditsGranted(string $creditsGranted): static
    {
        $this->creditsGranted = $creditsGranted;
        return $this;
    }

    public function getGemsGranted(): int
    {
        return $this->gemsGranted;
    }

    public function setGemsGranted(int $gemsGranted): static
    {
        $this->gemsGranted = $gemsGranted;
        return $this;
    }

    public function getPaymentMethod(): string
    {
        return $this->paymentMethod;
    }

    public function setPaymentMethod(string $paymentMethod): static
    {
        $this->paymentMethod = $paymentMethod;
        return $this;
    }

    public function getPaymentReference(): ?string
    {
        return $this->paymentReference;
    }

    public function setPaymentReference(?string $paymentReference): static
    {
        $this->paymentReference = $paymentReference;
        return $this;
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

    public function getCompletedAt(): ?\DateTimeInterface
    {
        return $this->completedAt;
    }

    public function setCompletedAt(?\DateTimeInterface $completedAt): static
    {
        $this->completedAt = $completedAt;
        return $this;
    }

    #[Groups(['topUpOrder:read'])]
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
