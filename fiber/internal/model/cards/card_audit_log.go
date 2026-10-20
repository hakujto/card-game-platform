package model_cards

import "time"

type CardAuditLog struct {
	ID        uint      `gorm:"primaryKey;autoIncrement"`
	RecordID  uint      `gorm:"column:record_id;not null"`
	Field     string    `gorm:"column:field;size:100;not null"`
	OldValue  *string   `gorm:"column:old_value;type:text"`
	NewValue  *string   `gorm:"column:new_value;type:text"`

	ChangedAt time.Time `gorm:"column:changed_at;autoCreateTime"`
}

func (CardAuditLog) TableName() string { return "cards_audit_logs" }
