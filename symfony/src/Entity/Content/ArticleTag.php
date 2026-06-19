<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\ArticleTagRepository;
use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;

#[ORM\Entity(repositoryClass: ArticleTagRepository::class)]
#[ORM\Table(name: 'article_tag')]
#[UniqueEntity(fields: ['slug'], message: 'slug must be unique')]
class ArticleTag
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['articleTag:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 100)]
    #[Groups(['articleTag:read', 'articleTag:write'])]
    private string $name = '';

    #[ORM\Column(type: 'string', length: 100, unique: true)]
    #[Groups(['articleTag:read', 'articleTag:write'])]
    private string $slug = '';

    #[ORM\OneToMany(mappedBy: 'tag', targetEntity: ArticleTagAssignment::class)]
    private Collection $articleAssignments;

    public function __construct()
    {
        $this->articleAssignments = new ArrayCollection();
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

    public function getSlug(): string
    {
        return $this->slug;
    }

    public function setSlug(string $slug): static
    {
        $this->slug = $slug;
        return $this;
    }

    public function getArticleAssignments(): Collection
    {
        return $this->articleAssignments;
    }

    // ── Business operations ──────────────────────────────────────────

    public function rename($newName): void
    {
        // TODO: implement rename
    }

    public function articleCount(): mixed
    {
        // TODO: implement article_count
        return null;
    }

}
