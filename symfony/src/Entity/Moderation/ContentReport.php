<?php

namespace App\Entity\Moderation;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Moderation\ContentReportRepository;
use App\Entity\Players\Player;
use App\Entity\Content\Article;
use App\Entity\Content\ArticleComment;

#[ORM\Entity(repositoryClass: ContentReportRepository::class)]
#[ORM\Table(name: 'content_report')]
class ContentReport
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['contentReport:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['contentReport:read', 'contentReport:write'])]
    private string $targetType = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['contentReport:read', 'contentReport:write'])]
    private string $reason = '';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['contentReport:read', 'contentReport:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['contentReport:read', 'contentReport:write'])]
    private string $status = 'Open';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['contentReport:read', 'contentReport:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['contentReport:read', 'contentReport:write'])]
    private ?\DateTimeInterface $reviewedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'content_reports')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $reporter = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'content_reports_reviewed')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Player $reviewedBy = null;

    #[ORM\ManyToOne(targetEntity: Article::class, inversedBy: 'reports')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Article $article = null;

    #[ORM\ManyToOne(targetEntity: ArticleComment::class, inversedBy: 'reports')]
    #[ORM\JoinColumn(nullable: true)]
    private ?ArticleComment $articleComment = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getTargetType(): string
    {
        return $this->targetType;
    }

    public function setTargetType(string $targetType): static
    {
        $this->targetType = $targetType;
        return $this;
    }

    public function getReason(): string
    {
        return $this->reason;
    }

    public function setReason(string $reason): static
    {
        $this->reason = $reason;
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

    public function getReviewedAt(): ?\DateTimeInterface
    {
        return $this->reviewedAt;
    }

    public function setReviewedAt(?\DateTimeInterface $reviewedAt): static
    {
        $this->reviewedAt = $reviewedAt;
        return $this;
    }

    #[Groups(['contentReport:read'])]
    public function getReporterId(): ?int
    {
        return $this->reporter?->getId();
    }

    public function getReporter(): ?Player
    {
        return $this->reporter;
    }

    public function setReporter(?Player $reporter): static
    {
        $this->reporter = $reporter;
        return $this;
    }

    #[Groups(['contentReport:read'])]
    public function getReviewedById(): ?int
    {
        return $this->reviewedBy?->getId();
    }

    public function getReviewedBy(): ?Player
    {
        return $this->reviewedBy;
    }

    public function setReviewedBy(?Player $reviewedBy): static
    {
        $this->reviewedBy = $reviewedBy;
        return $this;
    }

    #[Groups(['contentReport:read'])]
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

    #[Groups(['contentReport:read'])]
    public function getArticleCommentId(): ?int
    {
        return $this->articleComment?->getId();
    }

    public function getArticleComment(): ?ArticleComment
    {
        return $this->articleComment;
    }

    public function setArticleComment(?ArticleComment $articleComment): static
    {
        $this->articleComment = $articleComment;
        return $this;
    }

}
