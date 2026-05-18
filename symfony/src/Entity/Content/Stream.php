<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\StreamRepository;
use App\Entity\Tournaments\Tournament;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: StreamRepository::class)]
#[ORM\Table(name: 'stream')]
class Stream
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['stream:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 300)]
    #[Groups(['stream:read', 'stream:write'])]
    private string $title = '';

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['stream:read', 'stream:write'])]
    private string $streamUrl = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['stream:read', 'stream:write'])]
    private string $platform = 'Twitch';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['stream:read', 'stream:write'])]
    private string $status = 'Scheduled';

    #[ORM\Column(type: 'integer')]
    #[Groups(['stream:read', 'stream:write'])]
    private int $viewerCountPeak = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['stream:read', 'stream:write'])]
    private ?\DateTimeInterface $scheduledStart = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['stream:read', 'stream:write'])]
    private ?\DateTimeInterface $actualStart = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['stream:read', 'stream:write'])]
    private ?\DateTimeInterface $endedAt = null;

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['stream:read', 'stream:write'])]
    private ?string $vodUrl = null;

    #[ORM\ManyToOne(targetEntity: Tournament::class, inversedBy: 'streams')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Tournament $tournament = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'streams')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $streamer = null;

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

    public function getStreamUrl(): string
    {
        return $this->streamUrl;
    }

    public function setStreamUrl(string $streamUrl): static
    {
        $this->streamUrl = $streamUrl;
        return $this;
    }

    public function getPlatform(): string
    {
        return $this->platform;
    }

    public function setPlatform(string $platform): static
    {
        $this->platform = $platform;
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

    public function getViewerCountPeak(): int
    {
        return $this->viewerCountPeak;
    }

    public function setViewerCountPeak(int $viewerCountPeak): static
    {
        $this->viewerCountPeak = $viewerCountPeak;
        return $this;
    }

    public function getScheduledStart(): ?\DateTimeInterface
    {
        return $this->scheduledStart;
    }

    public function setScheduledStart(?\DateTimeInterface $scheduledStart): static
    {
        $this->scheduledStart = $scheduledStart;
        return $this;
    }

    public function getActualStart(): ?\DateTimeInterface
    {
        return $this->actualStart;
    }

    public function setActualStart(?\DateTimeInterface $actualStart): static
    {
        $this->actualStart = $actualStart;
        return $this;
    }

    public function getEndedAt(): ?\DateTimeInterface
    {
        return $this->endedAt;
    }

    public function setEndedAt(?\DateTimeInterface $endedAt): static
    {
        $this->endedAt = $endedAt;
        return $this;
    }

    public function getVodUrl(): ?string
    {
        return $this->vodUrl;
    }

    public function setVodUrl(?string $vodUrl): static
    {
        $this->vodUrl = $vodUrl;
        return $this;
    }

    #[Groups(['stream:read'])]
    public function getTournamentId(): ?int
    {
        return $this->tournament?->getId();
    }

    public function getTournament(): ?Tournament
    {
        return $this->tournament;
    }

    public function setTournament(?Tournament $tournament): static
    {
        $this->tournament = $tournament;
        return $this;
    }

    #[Groups(['stream:read'])]
    public function getStreamerId(): ?int
    {
        return $this->streamer?->getId();
    }

    public function getStreamer(): ?Player
    {
        return $this->streamer;
    }

    public function setStreamer(?Player $streamer): static
    {
        $this->streamer = $streamer;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Peak viewer count must not be negative")]
    public function isViewerCountNotNegativeValid(): bool
    {
        return ($this->getViewerCountPeak() === null || $this->getViewerCountPeak() >= 0);
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getActualStart() !== null && !($this->getStatus() === 'LIVE')) {
            throw new \DomainException('actual_start_requires_live_or_ended');
        }
        if ($this->getEndedAt() !== null && !($this->getStatus() === 'ENDED')) {
            throw new \DomainException('ended_at can only be set when stream status is Ended');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function goLive(): void
    {
        throw new \RuntimeException('go_live not implemented');
    }

    public function end(): void
    {
        throw new \RuntimeException('end not implemented');
    }

    public function updateViewerPeak($count): void
    {
        throw new \RuntimeException('update_viewer_peak not implemented');
    }

    public function durationMinutes(): void
    {
        throw new \RuntimeException('duration_minutes not implemented');
    }

}
