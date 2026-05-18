package model_tournaments

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

type TournamentPrizePrizeTypeType string
const (
	TournamentPrizePrizeTypeType_Currency TournamentPrizePrizeTypeType = "Currency"
	TournamentPrizePrizeTypeType_Cards TournamentPrizePrizeTypeType = "Cards"
	TournamentPrizePrizeTypeType_BoosterPacks TournamentPrizePrizeTypeType = "BoosterPacks"
	TournamentPrizePrizeTypeType_Trophy TournamentPrizePrizeTypeType = "Trophy"
	TournamentPrizePrizeTypeType_SeasonPoints TournamentPrizePrizeTypeType = "SeasonPoints"
	TournamentPrizePrizeTypeType_Mixed TournamentPrizePrizeTypeType = "Mixed"
)

// TournamentPrizeCreateRequest is the POST body.
type TournamentPrizeCreateRequest struct {
	PlacementFrom int `json:"placement_from"`
	PlacementTo int `json:"placement_to"`
	PrizeType TournamentPrizePrizeTypeType `json:"prize_type" binding:"required"`
	Amount types.Decimal `json:"amount"`
	Description *string `json:"description"`
	PacksCount *int `json:"packs_count"`
	SeasonPoints int `json:"season_points"`
	TournamentID uint `json:"tournament_id"`
}

// TournamentPrizeUpdateRequest is the PUT/PATCH body — all fields optional.
type TournamentPrizeUpdateRequest struct {
	PlacementFrom *int `json:"placement_from"`
	PlacementTo *int `json:"placement_to"`
	PrizeType *TournamentPrizePrizeTypeType `json:"prize_type"`
	Amount *types.Decimal `json:"amount"`
	Description *string `json:"description"`
	PacksCount *int `json:"packs_count"`
	SeasonPoints *int `json:"season_points"`
	TournamentID *uint `json:"tournament_id"`
}

// TournamentPrizeResponse is the JSON representation returned by the API.
type TournamentPrizeResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	PlacementFrom int `json:"placement_from"`
	PlacementTo int `json:"placement_to"`
	PrizeType TournamentPrizePrizeTypeType `json:"prize_type"`
	Amount types.Decimal `json:"amount"`
	Description *string `json:"description"`
	PacksCount *int `json:"packs_count"`
	SeasonPoints int `json:"season_points"`
	TournamentID uint `json:"tournament_id"`
}

type TournamentPrize struct {
	gorm.Model
	PlacementFrom int `gorm:"column:placement_from;not null"`
	PlacementTo int `gorm:"column:placement_to;not null"`
	PrizeType TournamentPrizePrizeTypeType `gorm:"column:prize_type;not null"`
	Amount types.Decimal `gorm:"column:amount;type:decimal(10,2);not null;default:0"`
	Description *string `gorm:"column:description;type:text"`
	PacksCount *int `gorm:"column:packs_count"`
	SeasonPoints int `gorm:"column:season_points;not null;default:0"`
	TournamentID uint `gorm:"column:tournament_id"`
}

func (m *TournamentPrize) ToResponse() TournamentPrizeResponse {
	return TournamentPrizeResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		PlacementFrom: m.PlacementFrom,
		PlacementTo: m.PlacementTo,
		PrizeType: m.PrizeType,
		Amount: m.Amount,
		Description: m.Description,
		PacksCount: m.PacksCount,
		SeasonPoints: m.SeasonPoints,
		TournamentID: m.TournamentID,
	}
}

func (m *TournamentPrize) ApplyUpdate(req TournamentPrizeUpdateRequest) {
	if req.PlacementFrom != nil { m.PlacementFrom = *req.PlacementFrom }
	if req.PlacementTo != nil { m.PlacementTo = *req.PlacementTo }
	if req.PrizeType != nil { m.PrizeType = *req.PrizeType }
	if req.Amount != nil { m.Amount = *req.Amount }
	if req.Description != nil { m.Description = req.Description }
	if req.PacksCount != nil { m.PacksCount = req.PacksCount }
	if req.SeasonPoints != nil { m.SeasonPoints = *req.SeasonPoints }
	if req.TournamentID != nil { m.TournamentID = *req.TournamentID }
}

func (m *TournamentPrize) AppliesToPlacement(placement int)  (bool, error) {
	return false, fmt.Errorf("AppliesToPlacement: not implemented")
}

func (m *TournamentPrize) AwardToPlayer(playerId int)  error {
	return fmt.Errorf("AwardToPlayer: not implemented")
}
