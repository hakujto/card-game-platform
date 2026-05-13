<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\ArticleTagRepository;

#[ORM\Entity(repositoryClass: ArticleTagRepository::class)]
#[ORM\Table(name: 'article_tag')]
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

    #[ORM\Column(type: 'string', length: 100)]
    #[Groups(['articleTag:read', 'articleTag:write'])]
    private string $slug = '';

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

    // ── Business operations ──────────────────────────────────────────

    public function rename($newName): void
    {
        throw new \RuntimeException('rename not implemented');
    }

    public function articleCount(): void
    {
        throw new \RuntimeException('article_count not implemented');
    }

}
