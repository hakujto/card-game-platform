package cardsproject.domain.content;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

@Entity
@Table(name = "streams")
public class Stream {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title = "";
    private String streamUrl = "";
    @Enumerated(EnumType.STRING)
    private StreamStatusType status;
    @Enumerated(EnumType.STRING)
    private StreamPlatformType platform;
    @Enumerated(EnumType.STRING)
    private StreamLanguageType language;
    private Boolean isOfficial = false;
    private Integer viewerCountPeak = 0;
    private LocalDateTime scheduledStart;
    private LocalDateTime actualStart;
    private LocalDateTime endedAt;
    private String vodUrl;

    // @ManyToOne -> Tournament, onDelete=SET_NULL, relatedName=streams, via=tournaments
    @Column(name = "tournament_id")
    private Long tournamentId;
    // @ManyToOne -> Player, onDelete=PROTECT, relatedName=streams, via=players
    @Column(name = "streamer_id")
    private Long streamerId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getStreamUrl() { return streamUrl; }
    public void setStreamUrl(String streamUrl) { this.streamUrl = streamUrl; }
    public StreamStatusType getStatus() { return status; }
    public void setStatus(StreamStatusType status) { this.status = status; }
    public StreamPlatformType getPlatform() { return platform; }
    public void setPlatform(StreamPlatformType platform) { this.platform = platform; }
    public StreamLanguageType getLanguage() { return language; }
    public void setLanguage(StreamLanguageType language) { this.language = language; }
    public Boolean getIsOfficial() { return isOfficial; }
    public void setIsOfficial(Boolean isOfficial) { this.isOfficial = isOfficial; }
    public Integer getViewerCountPeak() { return viewerCountPeak; }
    public void setViewerCountPeak(Integer viewerCountPeak) { this.viewerCountPeak = viewerCountPeak; }
    @JsonProperty("scheduledStart")
    public LocalDateTime getScheduledStart() { return scheduledStart; }
    public void setScheduledStart(LocalDateTime scheduledStart) { this.scheduledStart = scheduledStart; }
    @JsonProperty("actualStart")
    public LocalDateTime getActualStart() { return actualStart; }
    public void setActualStart(LocalDateTime actualStart) { this.actualStart = actualStart; }
    @JsonProperty("endedAt")
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
        // TODO: implement goLive
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public void end() {
        // TODO: implement end
    }
    public void updateViewerPeak(Integer count) {
        // TODO: implement updateViewerPeak
    }
    @com.fasterxml.jackson.annotation.JsonIgnore
    public Integer durationMinutes() {
        // TODO: implement durationMinutes
        return null;
    }

    // ── Validation rules ─────────────────────────────────────────────
    @jakarta.validation.constraints.AssertTrue(message = "Peak viewer count must not be negative")
    @com.fasterxml.jackson.annotation.JsonIgnore
    public boolean isViewerCountNotNegativeValid() {
        return (getViewerCountPeak() == null || getViewerCountPeak() >= 0);
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    private static final java.util.Map<StreamStatusType, java.util.List<StreamStatusType>> ALLOWED_TRANSITIONS =
        java.util.Map.ofEntries(
        java.util.Map.entry(StreamStatusType.SCHEDULED, java.util.List.of(StreamStatusType.LIVE)),
        java.util.Map.entry(StreamStatusType.LIVE, java.util.List.of(StreamStatusType.ENDED))
        );

    public void assertTransition(StreamStatusType to) {
        java.util.List<StreamStatusType> allowed = ALLOWED_TRANSITIONS.getOrDefault(this.getStatus(), java.util.List.of());
        if (!allowed.contains(to)) {
            throw new IllegalStateException("Transition " + this.getStatus() + " -> " + to + " not allowed");
        }
    }
}
