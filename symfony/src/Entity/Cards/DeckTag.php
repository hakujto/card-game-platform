<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\DeckTagRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;

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

    #[ORM\OneToMany(mappedBy: 'tag', targetEntity: DeckTagAssignment::class)]
    private Collection $deckAssignments;

    public function __construct()
    {
        $this->deckAssignments = new ArrayCollection();
    }

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

    public function getDeckAssignments(): Collection
    {
        return $this->deckAssignments;
    }

    // ── Business operations ──────────────────────────────────────────

    public function rename($newName): void
    {
        // TODO: implement rename
    }

    public function mergeInto($targetTagId): void
    {
        // TODO: implement merge_into
    }

}
