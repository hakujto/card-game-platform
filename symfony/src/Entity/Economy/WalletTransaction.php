<?php

namespace App\Entity\Economy;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Economy\WalletTransactionRepository;
use App\Entity\Marketplace\Order;
use App\Entity\Marketplace\TradeTransaction;

#[ORM\Entity(repositoryClass: WalletTransactionRepository::class)]
#[ORM\Table(name: 'wallet_transaction')]
class WalletTransaction
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['walletTransaction:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['walletTransaction:read', 'walletTransaction:write'])]
    private string $transactionType = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['walletTransaction:read', 'walletTransaction:write'])]
    private string $currency = '';

    #[ORM\Column(type: 'decimal', precision: 12, scale: 2)]
    #[Groups(['walletTransaction:read', 'walletTransaction:write'])]
    private string $amount = '0.00';

    #[ORM\Column(type: 'decimal', precision: 12, scale: 2)]
    #[Groups(['walletTransaction:read', 'walletTransaction:write'])]
    private string $balanceAfter = '0.00';

    #[ORM\Column(type: 'string', length: 300, nullable: true)]
    #[Groups(['walletTransaction:read', 'walletTransaction:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['walletTransaction:read', 'walletTransaction:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Wallet::class, inversedBy: 'transactions')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Wallet $wallet = null;

    #[ORM\ManyToOne(targetEntity: Order::class, inversedBy: 'wallet_transactions')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Order $order = null;

    #[ORM\ManyToOne(targetEntity: TradeTransaction::class, inversedBy: 'wallet_transactions')]
    #[ORM\JoinColumn(nullable: true)]
    private ?TradeTransaction $tradeTransaction = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getTransactionType(): string
    {
        return $this->transactionType;
    }

    public function setTransactionType(string $transactionType): static
    {
        $this->transactionType = $transactionType;
        return $this;
    }

    public function getCurrency(): string
    {
        return $this->currency;
    }

    public function setCurrency(string $currency): static
    {
        $this->currency = $currency;
        return $this;
    }

    public function getAmount(): string
    {
        return $this->amount;
    }

    public function setAmount(string $amount): static
    {
        $this->amount = $amount;
        return $this;
    }

    public function getBalanceAfter(): string
    {
        return $this->balanceAfter;
    }

    public function setBalanceAfter(string $balanceAfter): static
    {
        $this->balanceAfter = $balanceAfter;
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

    public function getCreatedAt(): ?\DateTimeInterface
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?\DateTimeInterface $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    #[Groups(['walletTransaction:read'])]
    public function getWalletId(): ?int
    {
        return $this->wallet?->getId();
    }

    public function getWallet(): ?Wallet
    {
        return $this->wallet;
    }

    public function setWallet(?Wallet $wallet): static
    {
        $this->wallet = $wallet;
        return $this;
    }

    #[Groups(['walletTransaction:read'])]
    public function getOrderId(): ?int
    {
        return $this->order?->getId();
    }

    public function getOrder(): ?Order
    {
        return $this->order;
    }

    public function setOrder(?Order $order): static
    {
        $this->order = $order;
        return $this;
    }

    #[Groups(['walletTransaction:read'])]
    public function getTradeTransactionId(): ?int
    {
        return $this->tradeTransaction?->getId();
    }

    public function getTradeTransaction(): ?TradeTransaction
    {
        return $this->tradeTransaction;
    }

    public function setTradeTransaction(?TradeTransaction $tradeTransaction): static
    {
        $this->tradeTransaction = $tradeTransaction;
        return $this;
    }

}
