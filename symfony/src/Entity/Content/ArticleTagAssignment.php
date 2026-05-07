<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\ArticleTagAssignmentRepository;

#[ORM\Entity(repositoryClass: ArticleTagAssignmentRepository::class)]
#[ORM\Table(name: 'article_tag_assignment')]
class ArticleTagAssignment
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['articleTagAssignment:read'])]
    private ?int $id = null;

    #[ORM\ManyToOne(targetEntity: Article::class, inversedBy: 'tag_assignments')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Article $article = null;

    #[ORM\ManyToOne(targetEntity: ArticleTag::class, inversedBy: 'article_assignments')]
    #[ORM\JoinColumn(nullable: false)]
    private ?ArticleTag $tag = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    #[Groups(['articleTagAssignment:read'])]
    public function getArticleId(): ?int
    {
        return $this->article?->getId();
    }

    public function getArticle(): ?Article
    {
        return $this->article;
    }

    public function setArticle(?Article $article): static
    {
        $this->article = $article;
        return $this;
    }

    #[Groups(['articleTagAssignment:read'])]
    public function getTagId(): ?int
    {
        return $this->tag?->getId();
    }

    public function getTag(): ?ArticleTag
    {
        return $this->tag;
    }

    public function setTag(?ArticleTag $tag): static
    {
        $this->tag = $tag;
        return $this;
    }

}
