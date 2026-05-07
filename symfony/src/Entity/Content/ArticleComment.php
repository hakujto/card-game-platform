<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\ArticleCommentRepository;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: ArticleCommentRepository::class)]
#[ORM\Table(name: 'article_comment')]
class ArticleComment
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['articleComment:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'text')]
    #[Groups(['articleComment:read', 'articleComment:write'])]
    private string $body = '';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['articleComment:read', 'articleComment:write'])]
    private bool $isHidden = false;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['articleComment:read', 'articleComment:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Article::class, inversedBy: 'comments')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Article $article = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'article_comments')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $author = null;

    #[ORM\ManyToOne(targetEntity: ArticleComment::class, inversedBy: 'replies')]
    #[ORM\JoinColumn(nullable: true)]
    private ?ArticleComment $parentComment = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getBody(): string
    {
        return $this->body;
    }

    public function setBody(string $body): static
    {
        $this->body = $body;
        return $this;
    }

    public function getIsHidden(): bool
    {
        return $this->isHidden;
    }

    public function setIsHidden(bool $isHidden): static
    {
        $this->isHidden = $isHidden;
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

    #[Groups(['articleComment:read'])]
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

    #[Groups(['articleComment:read'])]
    public function getAuthorId(): ?int
    {
        return $this->author?->getId();
    }

    public function getAuthor(): ?Player
    {
        return $this->author;
    }

    public function setAuthor(?Player $author): static
    {
        $this->author = $author;
        return $this;
    }

    #[Groups(['articleComment:read'])]
    public function getParentCommentId(): ?int
    {
        return $this->parentComment?->getId();
    }

    public function getParentComment(): ?ArticleComment
    {
        return $this->parentComment;
    }

    public function setParentComment(?ArticleComment $parentComment): static
    {
        $this->parentComment = $parentComment;
        return $this;
    }

}
