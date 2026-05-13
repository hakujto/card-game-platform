<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\DeckTagRepository;

#[ORM\Entity(repositoryClass: DeckTagRepository::class)]
#[ORM\Table(name: 'deck_tag')]
class DeckTag
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['deckTag:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 50)]
    #[Groups(['deckTag:read', 'deckTag:write'])]
    private string $name = '';

    #[ORM\Column(type: 'string', length: 7, nullable: true)]
    #[Groups(['deckTag:read', 'deckTag:write'])]
    private ?string $color = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }

    public function getColor(): ?string
    {
        return $this->color;
    }

    public function setColor(?string $color): static
    {
        $this->color = $color;
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function rename($newName): void
    {
        throw new \RuntimeException('rename not implemented');
    }

    public function mergeInto($targetTagId): void
    {
        throw new \RuntimeException('merge_into not implemented');
    }

}
