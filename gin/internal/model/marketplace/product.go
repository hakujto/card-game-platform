package model_marketplace

import (
	"time"

	"gorm.io/gorm"
	"cards_project/internal/types"
	"fmt"
)

type ProductProductTypeType string
const (
	ProductProductTypeType_SingleCard ProductProductTypeType = "SingleCard"
	ProductProductTypeType_BoosterPack ProductProductTypeType = "BoosterPack"
	ProductProductTypeType_Bundle ProductProductTypeType = "Bundle"
	ProductProductTypeType_PreconstructedDeck ProductProductTypeType = "PreconstructedDeck"
	ProductProductTypeType_Accessory ProductProductTypeType = "Accessory"
)

// ProductCreateRequest is the POST body.
type ProductCreateRequest struct {
	Name string `json:"name" binding:"required"`
	ProductType ProductProductTypeType `json:"product_type" binding:"required"`
	Price types.Decimal `json:"price"`
	Stock int `json:"stock"`
	Active bool `json:"active"`
	DiscountPercent int `json:"discount_percent"`
	Description *string `json:"description"`
	ImageUrl *string `json:"image_url"`
	Featured bool `json:"featured"`
	CardID *uint `json:"card_id"`
	CardSetID *uint `json:"card_set_id"`
}

// ProductUpdateRequest is the PUT/PATCH body — all fields optional.
type ProductUpdateRequest struct {
	Name *string `json:"name"`
	ProductType *ProductProductTypeType `json:"product_type"`
	Price *types.Decimal `json:"price"`
	Stock *int `json:"stock"`
	Active *bool `json:"active"`
	DiscountPercent *int `json:"discount_percent"`
	Description *string `json:"description"`
	ImageUrl *string `json:"image_url"`
	Featured *bool `json:"featured"`
	CardID *uint `json:"card_id"`
	CardSetID *uint `json:"card_set_id"`
}

// ProductResponse is the JSON representation returned by the API.
type ProductResponse struct {
	ID        uint      `json:"id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
	Name string `json:"name"`
	ProductType ProductProductTypeType `json:"product_type"`
	Price types.Decimal `json:"price"`
	Stock int `json:"stock"`
	Active bool `json:"active"`
	DiscountPercent int `json:"discount_percent"`
	Description *string `json:"description"`
	ImageUrl *string `json:"image_url"`
	Featured bool `json:"featured"`
	CardID *uint `json:"card_id"`
	CardSetID *uint `json:"card_set_id"`
}

type Product struct {
	gorm.Model
	Name string `gorm:"column:name;not null"`
	ProductType ProductProductTypeType `gorm:"column:product_type;not null;default:'SingleCard'"`
	Price types.Decimal `gorm:"column:price;type:decimal(10,2);not null"`
	Stock int `gorm:"column:stock;not null;default:0"`
	Active bool `gorm:"column:active;default:true"`
	DiscountPercent int `gorm:"column:discount_percent;not null;default:0"`
	Description *string `gorm:"column:description;type:text"`
	ImageUrl *string `gorm:"column:image_url"`
	Featured bool `gorm:"column:featured;default:false"`
	CardID *uint `gorm:"column:card_id"`
	CardSetID *uint `gorm:"column:card_set_id"`
}

func (m *Product) ToResponse() ProductResponse {
	return ProductResponse{
		ID:        m.ID,
		CreatedAt: m.CreatedAt,
		UpdatedAt: m.UpdatedAt,
		Name: m.Name,
		ProductType: m.ProductType,
		Price: m.Price,
		Stock: m.Stock,
		Active: m.Active,
		DiscountPercent: m.DiscountPercent,
		Description: m.Description,
		ImageUrl: m.ImageUrl,
		Featured: m.Featured,
		CardID: m.CardID,
		CardSetID: m.CardSetID,
	}
}

func (m *Product) ApplyUpdate(req ProductUpdateRequest) {
	if req.Name != nil { m.Name = *req.Name }
	if req.ProductType != nil { m.ProductType = *req.ProductType }
	if req.Price != nil { m.Price = *req.Price }
	if req.Stock != nil { m.Stock = *req.Stock }
	if req.Active != nil { m.Active = *req.Active }
	if req.DiscountPercent != nil { m.DiscountPercent = *req.DiscountPercent }
	if req.Description != nil { m.Description = req.Description }
	if req.ImageUrl != nil { m.ImageUrl = req.ImageUrl }
	if req.Featured != nil { m.Featured = *req.Featured }
	if req.CardID != nil { m.CardID = req.CardID }
	if req.CardSetID != nil { m.CardSetID = req.CardSetID }
}

func (m *Product) Activate()  error {
	return fmt.Errorf("Activate: not implemented")
}

func (m *Product) Deactivate()  error {
	return fmt.Errorf("Deactivate: not implemented")
}

func (m *Product) ApplyDiscount(percent int)  (float64, error) {
	return 0.0, fmt.Errorf("ApplyDiscount: not implemented")
}

func (m *Product) Restock(quantity int)  error {
	return fmt.Errorf("Restock: not implemented")
}

func (m *Product) EffectivePrice()  (float64, error) {
	return 0.0, fmt.Errorf("EffectivePrice: not implemented")
}

func (m *Product) IsInStock()  (bool, error) {
	return false, fmt.Errorf("IsInStock: not implemented")
}
