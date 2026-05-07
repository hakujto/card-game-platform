<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\CardRulingRepository;

#[ORM\Entity(repositoryClass: CardRulingRepository::class)]
#[ORM\Table(name: 'card_ruling')]
class CardRuling
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['cardRuling:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'text')]
    #[Groups(['cardRuling:read', 'cardRuling:write'])]
    private string $rulingText = '';

    #[ORM\Column(type: 'date', nullable: true)]
    #[Groups(['cardRuling:read', 'cardRuling:write'])]
    private ?\DateTimeInterface $publishedAt = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['cardRuling:read', 'cardRuling:write'])]
    private string $source = '';

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'rulings')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $card = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getRulingText(): string
    {
        return $this->rulingText;
    }

    public function setRulingText(string $rulingText): static
    {
        $this->rulingText = $rulingText;
        return $this;
    }

    public function getPublishedAt(): ?\DateTimeInterface
    {
        return $this->publishedAt;
    }

    public function setPublishedAt(?\DateTimeInterface $publishedAt): static
    {
        $this->publishedAt = $publishedAt;
        return $this;
    }

    public function getSource(): string
    {
        return $this->source;
    }

    public function setSource(string $source): static
    {
        $this->source = $source;
        return $this;
    }

    #[Groups(['cardRuling:read'])]
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

}
