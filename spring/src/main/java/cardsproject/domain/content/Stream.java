package cardsproject.domain.content;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "streams")
public class Stream {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title = "";
    private String streamUrl = "";
    @Enumerated(EnumType.STRING)
    private StreamPlatformType platform;
    @Enumerated(EnumType.STRING)
    private StreamStatusType status;
    private Integer viewerCountPeak = 0;
    private LocalDateTime scheduledStart;
    private LocalDateTime actualStart;
    private LocalDateTime endedAt;
    private String vodUrl;

    @Column(name = "tournament_id")
    private Long tournamentId;
    @Column(name = "streamer_id")
    private Long streamerId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getStreamUrl() { return streamUrl; }
    public void setStreamUrl(String streamUrl) { this.streamUrl = streamUrl; }
    public StreamPlatformType getPlatform() { return platform; }
    public void setPlatform(StreamPlatformType platform) { this.platform = platform; }
    public StreamStatusType getStatus() { return status; }
    public void setStatus(StreamStatusType status) { this.status = status; }
    public Integer getViewerCountPeak() { return viewerCountPeak; }
    public void setViewerCountPeak(Integer viewerCountPeak) { this.viewerCountPeak = viewerCountPeak; }
    public LocalDateTime getScheduledStart() { return scheduledStart; }
    public void setScheduledStart(LocalDateTime scheduledStart) { this.scheduledStart = scheduledStart; }
    public LocalDateTime getActualStart() { return actualStart; }
    public void setActualStart(LocalDateTime actualStart) { this.actualStart = actualStart; }
    public LocalDateTime getEndedAt() { return endedAt; }
    public void setEndedAt(LocalDateTime endedAt) { this.endedAt = endedAt; }
    public String getVodUrl() { return vodUrl; }
    public void setVodUrl(String vodUrl) { this.vodUrl = vodUrl; }
    public Long getTournamentId() { return tournamentId; }
    public void setTournamentId(Long tournamentId) { this.tournamentId = tournamentId; }
    public Long getStreamerId() { return streamerId; }
    public void setStreamerId(Long streamerId) { this.streamerId = streamerId; }

    // ── Business operations ──────────────────────────────────────────
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void goLive() {
        throw new UnsupportedOperationException("goLive not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void end() {
        throw new UnsupportedOperationException("end not implemented");
    }
    public void updateViewerPeak(Integer count) {
        throw new UnsupportedOperationException("updateViewerPeak not implemented");
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Integer durationMinutes() {
        throw new UnsupportedOperationException("durationMinutes not implemented");
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Peak viewer count must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isViewerCountNotNegativeValid() {
        return (getViewerCountPeak() == null || getViewerCountPeak() >= 0);
    }
}
