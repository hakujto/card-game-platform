package model_content

import (
	"time"

	"gorm.io/gorm"
	"fmt"
)

type StreamStatusType string
const (
	StreamStatusType_Scheduled StreamStatusType = "Scheduled"
	StreamStatusType_Live StreamStatusType = "Live"
	StreamStatusType_Ended StreamStatusType = "Ended"
)

type StreamPlatformType string
const (
	StreamPlatformType_Twitch StreamPlatformType = "Twitch"
	StreamPlatformType_YouTube StreamPlatformType = "YouTube"
	StreamPlatformType_KickStream StreamPlatformType = "KickStream"
	StreamPlatformType_Platform StreamPlatformType = "Platform"
)

type StreamLanguageType string
const (
	StreamLanguageType_EN StreamLanguageType = "EN"
	StreamLanguageType_DE StreamLanguageType = "DE"
	StreamLanguageType_FR StreamLanguageType = "FR"
	StreamLanguageType_IT StreamLanguageType = "IT"
	StreamLanguageType_ES StreamLanguageType = "ES"
	StreamLanguageType_JP StreamLanguageType = "JP"
	StreamLanguageType_PT StreamLanguageType = "PT"
)

// StreamCreateRequest is the POST body.
type StreamCreateRequest struct {
	Title string `json:"title" binding:"required"`
	StreamUrl string `json:"stream_url" binding:"required"`
	Status StreamStatusType `json:"status" binding:"required"`
	Platform StreamPlatformType `json:"platform" binding:"required"`
	Language StreamLanguageType `json:"language" binding:"required"`
	IsOfficial bool `json:"is_official"`
	ViewerCountPeak int `json:"viewer_count_peak"`
	ScheduledStart string `json:"scheduled_start" binding:"required"`
	ActualStart *string `json:"actual_start"`
	EndedAt *string `json:"ended_at"`
	VodUrl *string `json:"vod_url"`
	TournamentID *uint `json:"tournament_id"`
	StreamerID uint `json:"streamer_id"`
}

// StreamUpdateRequest is the PUT/PATCH body — all fields optional.
type StreamUpdateRequest struct {
	Title *string `json:"title"`
	StreamUrl *string `json:"stream_url"`
	Status *StreamStatusType `json:"status"`
	Platform *StreamPlatformType `json:"platform"`
	Language *StreamLanguageType `json:"language"`
	IsOfficial *bool `json:"is_official"`
	ViewerCountPeak *int `json:"viewer_count_peak"`
	ScheduledStart *string `json:"scheduled_start"`
	ActualStart *string `json:"actual_start"`
	EndedAt *string `json:"ended_at"`
	VodUrl *string `json:"vod_url"`
	TournamentID *uint `json:"tournament_id"`
	StreamerID *uint `json:"streamer_id"`
}

// StreamResponse is the JSON representation returned by the API.
type StreamResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Title string `json:"title"`
	StreamUrl string `json:"stream_url"`
	Status StreamStatusType `json:"status"`
	Platform StreamPlatformType `json:"platform"`
	Language StreamLanguageType `json:"language"`
	IsOfficial bool `json:"is_official"`
	ViewerCountPeak int `json:"viewer_count_peak"`
	ScheduledStart string `json:"scheduledStart"`
	ActualStart *string `json:"actualStart"`
	EndedAt *string `json:"endedAt"`
	VodUrl *string `json:"vod_url"`
	TournamentID *uint `json:"tournament_id"`
	StreamerID uint `json:"streamer_id"`
}

type Stream struct {
	gorm.Model
	Title string `gorm:"column:title;not null"`
	StreamUrl string `gorm:"column:stream_url;not null"`
	Status StreamStatusType `gorm:"column:status;not null;default:'Scheduled'"`
	Platform StreamPlatformType `gorm:"column:platform;not null;default:'Twitch'"`
	Language StreamLanguageType `gorm:"column:language;not null;default:'EN'"`
	IsOfficial bool `gorm:"column:is_official;default:false"`
	ViewerCountPeak int `gorm:"column:viewer_count_peak;not null;default:0"`
	ScheduledStart string `gorm:"column:scheduled_start;not null"`
	ActualStart *string `gorm:"column:actual_start"`
	EndedAt *string `gorm:"column:ended_at"`
	VodUrl *string `gorm:"column:vod_url"`
	TournamentID *uint `gorm:"column:tournament_id"`
	StreamerID uint `gorm:"column:streamer_id"`
}

func (m *Stream) ToResponse() StreamResponse {
	return StreamResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Title: m.Title,
		StreamUrl: m.StreamUrl,
		Status: m.Status,
		Platform: m.Platform,
		Language: m.Language,
		IsOfficial: m.IsOfficial,
		ViewerCountPeak: m.ViewerCountPeak,
		ScheduledStart: m.ScheduledStart,
		ActualStart: m.ActualStart,
		EndedAt: m.EndedAt,
		VodUrl: m.VodUrl,
		TournamentID: m.TournamentID,
		StreamerID: m.StreamerID,
	}
}

func (m *Stream) ApplyUpdate(req StreamUpdateRequest) {
	if req.Title != nil { m.Title = *req.Title }
	if req.StreamUrl != nil { m.StreamUrl = *req.StreamUrl }
	if req.Status != nil { m.Status = *req.Status }
	if req.Platform != nil { m.Platform = *req.Platform }
	if req.Language != nil { m.Language = *req.Language }
	if req.IsOfficial != nil { m.IsOfficial = *req.IsOfficial }
	if req.ViewerCountPeak != nil { m.ViewerCountPeak = *req.ViewerCountPeak }
	if req.ScheduledStart != nil { m.ScheduledStart = *req.ScheduledStart }
	if req.ActualStart != nil { m.ActualStart = req.ActualStart }
	if req.EndedAt != nil { m.EndedAt = req.EndedAt }
	if req.VodUrl != nil { m.VodUrl = req.VodUrl }
	if req.TournamentID != nil { m.TournamentID = req.TournamentID }
	if req.StreamerID != nil { m.StreamerID = *req.StreamerID }
}

// ── Lifecycle state machine ──────────────────────────────────────
var StreamAllowedTransitions = map[string]map[string]bool{
		"Scheduled": {"Live": true},
		"Live": {"Ended": true},
}

func (m *Stream) AssertTransition(to string) error {
	current := string(m.Status)
	allowed, ok := StreamAllowedTransitions[current]
	if !ok || !allowed[to] {
		return fmt.Errorf("transition %s -> %s is not allowed", current, to)
	}
	return nil
}

// ── Business operations ──────────────────────────────────────────

func (m *Stream) GoLive()  error {
	return fmt.Errorf("GoLive: not implemented")
}

func (m *Stream) End()  error {
	return fmt.Errorf("End: not implemented")
}

func (m *Stream) UpdateViewerPeak(count int)  error {
	return fmt.Errorf("UpdateViewerPeak: not implemented")
}

func (m *Stream) DurationMinutes()  (int, error) {
	return 0, fmt.Errorf("DurationMinutes: not implemented")
}
