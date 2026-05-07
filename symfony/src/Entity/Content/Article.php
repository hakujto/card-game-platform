<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\ArticleRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\Players\Player;
use App\Entity\Cards\Deck;

#[ORM\Entity(repositoryClass: ArticleRepository::class)]
#[ORM\Table(name: 'article')]
class Article
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['article:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 300)]
    #[Groups(['article:read', 'article:write'])]
    private string $title = '';

    #[ORM\Column(type: 'string', length: 300)]
    #[Groups(['article:read', 'article:write'])]
    private string $slug = '';

    #[ORM\Column(type: 'text')]
    #[Groups(['article:read', 'article:write'])]
    private string $body = '';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['article:read', 'article:write'])]
    private ?string $excerpt = null;

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['article:read', 'article:write'])]
    private ?string $coverImageUrl = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['article:read', 'article:write'])]
    private string $status = 'Draft';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['article:read', 'article:write'])]
    private string $articleType = 'Guide';

    #[ORM\Column(type: 'integer')]
    #[Groups(['article:read', 'article:write'])]
    private int $viewCount = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['article:read', 'article:write'])]
    private ?\DateTimeInterface $publishedAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['article:read', 'article:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['article:read', 'article:write'])]
    private ?\DateTimeInterface $updatedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'articles')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $author = null;

    #[ORM\ManyToOne(targetEntity: Deck::class, inversedBy: 'articles')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Deck $featuredDeck = null;

    #[ORM\ManyToOne(targetEntity: ArticleComment::class, inversedBy: 'article')]
    #[ORM\JoinColumn(nullable: false)]
    private ?ArticleComment $comments = null;

    #[ORM\ManyToMany(targetEntity: ArticleTag::class)]
    #[ORM\JoinTable(name: 'article_tags_m2m')]
    private Collection $tags;

    public function __construct()
    {
        $this->tags = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getTitle(): string
    {
        return $this->title;
    }

    public function setTitle(string $title): static
    {
        $this->title = $title;
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

    public function getBody(): string
    {
        return $this->body;
    }

    public function setBody(string $body): static
    {
        $this->body = $body;
        return $this;
    }

    public function getExcerpt(): ?string
    {
        return $this->excerpt;
    }

    public function setExcerpt(?string $excerpt): static
    {
        $this->excerpt = $excerpt;
        return $this;
    }

    public function getCoverImageUrl(): ?string
    {
        return $this->coverImageUrl;
    }

    public function setCoverImageUrl(?string $coverImageUrl): static
    {
        $this->coverImageUrl = $coverImageUrl;
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

    public function getArticleType(): string
    {
        return $this->articleType;
    }

    public function setArticleType(string $articleType): static
    {
        $this->articleType = $articleType;
        return $this;
    }

    public function getViewCount(): int
    {
        return $this->viewCount;
    }

    public function setViewCount(int $viewCount): static
    {
        $this->viewCount = $viewCount;
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

    public function getCreatedAt(): ?\DateTimeInterface
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?\DateTimeInterface $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeInterface $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    #[Groups(['article:read'])]
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

    #[Groups(['article:read'])]
    public function getFeaturedDeckId(): ?int
    {
        return $this->featuredDeck?->getId();
    }

    public function getFeaturedDeck(): ?Deck
    {
        return $this->featuredDeck;
    }

    public function setFeaturedDeck(?Deck $featuredDeck): static
    {
        $this->featuredDeck = $featuredDeck;
        return $this;
    }

    #[Groups(['article:read'])]
    public function getCommentsId(): ?int
    {
        return $this->comments?->getId();
    }

    public function getComments(): ?ArticleComment
    {
        return $this->comments;
    }

    public function setComments(?ArticleComment $comments): static
    {
        $this->comments = $comments;
        return $this;
    }

    public function getTags(): Collection
    {
        return $this->tags;
    }

    public function addTags(ArticleTag $item): static
    {
        if (!$this->tags->contains($item)) {
            $this->tags->add($item);
        }
        return $this;
    }

    public function removeTags(ArticleTag $item): static
    {
        $this->tags->removeElement($item);
        return $this;
    }

}
