package handler_players

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	model "cards_project/internal/model/players"
	"cards_project/internal/handler"
)

type FriendshipHandler struct { db *gorm.DB }

func NewFriendshipHandler(db *gorm.DB) *FriendshipHandler {
	return &FriendshipHandler{db: db}
}

func (h *FriendshipHandler) RegisterRoutes(r gin.IRouter) {
	g := r.Group("/api/friendships")
	g.GET("", h.List)
	g.POST("", h.Create)
	g.GET("/:id", h.Get)
	g.PUT("/:id", h.Update)
	g.PATCH("/:id", h.Patch)
	g.DELETE("/:id", h.Delete)
	g.POST("/:id/accept", h.Accept)
	g.POST("/:id/decline", h.Decline)
	g.POST("/:id/block", h.Block)
}

func (h *FriendshipHandler) List(c *gin.Context) {
	skip, limit := handler.Paginate(c)
	var rows []model.Friendship
	if err := h.db.Offset(skip).Limit(limit).Find(&rows).Error; err != nil {
		handler.DbError(c, err); return
	}
	out := make([]model.FriendshipResponse, len(rows))
	for i := range rows { out[i] = rows[i].ToResponse() }
	c.JSON(http.StatusOK, out)
}

func (h *FriendshipHandler) Create(c *gin.Context) {
	var req model.FriendshipCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row := model.Friendship{}
	row.Status = req.Status
	row.RequesterID = req.RequesterID
	row.ReceiverID = req.ReceiverID
	if err := h.db.Create(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusCreated, row.ToResponse())
}

func (h *FriendshipHandler) Get(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Friendship"); return }
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *FriendshipHandler) Update(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Friendship"); return }
		handler.DbError(c, err); return
	}
	var req model.FriendshipUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		handler.ValidationError(c, err.Error()); return
	}
	row.ApplyUpdate(req)
	if err := h.db.Save(&row).Error; err != nil {
		handler.DbError(c, err); return
	}
	c.JSON(http.StatusOK, row.ToResponse())
}

func (h *FriendshipHandler) Patch(c *gin.Context) { h.Update(c) }

func (h *FriendshipHandler) Delete(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	if err := h.db.Delete(&model.Friendship{}, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Friendship"); return }
		handler.DbError(c, err); return
	}
	c.Status(http.StatusNoContent)
}

func (h *FriendshipHandler) Accept(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Friendship"); return }
		handler.DbError(c, err); return
	}
	err := row.Accept()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *FriendshipHandler) Decline(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Friendship"); return }
		handler.DbError(c, err); return
	}
	err := row.Decline()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}

func (h *FriendshipHandler) Block(c *gin.Context) {
	id, ok := handler.ParseID(c); if !ok { return }
	var row model.Friendship
	if err := h.db.First(&row, id).Error; err != nil {
		if handler.IsRecordNotFound(err) { handler.NotFound(c, "Friendship"); return }
		handler.DbError(c, err); return
	}
	err := row.Block()
	if err != nil { handler.DbError(c, err); return }
	h.db.Save(&row)
	c.Status(http.StatusNoContent)
}
