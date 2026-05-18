<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Players\PlayerCollectionRepository;
use App\Entity\Cards\Card;

#[ORM\Entity(repositoryClass: PlayerCollectionRepository::class)]
#[ORM\Table(name: 'player_collection')]
class PlayerCollection
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['playerCollection:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['playerCollection:read', 'playerCollection:write'])]
    private int $quantity = 1;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['playerCollection:read', 'playerCollection:write'])]
    private bool $foil = false;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['playerCollection:read', 'playerCollection:write'])]
    private string $condition = 'Mint';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['playerCollection:read', 'playerCollection:write'])]
    private ?\DateTimeInterface $acquiredAt = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['playerCollection:read', 'playerCollection:write'])]
    private string $acquiredVia = 'Purchase';

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'collection')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'player_collections')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $card = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getQuantity(): int
    {
        return $this->quantity;
    }

    public function setQuantity(int $quantity): static
    {
        $this->quantity = $quantity;
        return $this;
    }

    public function getFoil(): bool
    {
        return $this->foil;
    }

    public function setFoil(bool $foil): static
    {
        $this->foil = $foil;
        return $this;
    }

    public function getCondition(): string
    {
        return $this->condition;
    }

    public function setCondition(string $condition): static
    {
        $this->condition = $condition;
        return $this;
    }

    public function getAcquiredAt(): ?\DateTimeInterface
    {
        return $this->acquiredAt;
    }

    public function setAcquiredAt(?\DateTimeInterface $acquiredAt): static
    {
        $this->acquiredAt = $acquiredAt;
        return $this;
    }

    public function getAcquiredVia(): string
    {
        return $this->acquiredVia;
    }

    public function setAcquiredVia(string $acquiredVia): static
    {
        $this->acquiredVia = $acquiredVia;
        return $this;
    }

    #[Groups(['playerCollection:read'])]
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

    #[Groups(['playerCollection:read'])]
    public function getCardId(): ?int
    {
        return $this->card?->getId();
    }

    public function getCard(): ?Card
    {
        return $this->card;
    }

    public function setCard(?Card $card): static
    {
        $this->card = $card;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Collection quantity must be greater than zero")]
    public function isQuantityPositiveValid(): bool
    {
        return ($this->getQuantity() === null || $this->getQuantity() > 0);
    }

    // ── Business operations ──────────────────────────────────────────

    public function add($quantity): void
    {
        throw new \RuntimeException('add not implemented');
    }

    public function remove($quantity): void
    {
        throw new \RuntimeException('remove not implemented');
    }

    public function estimatedValue(): void
    {
        throw new \RuntimeException('estimated_value not implemented');
    }

}
