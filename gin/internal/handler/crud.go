package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// ParseID extracts and validates the :id path param.
func ParseID(c *gin.Context) (uint, bool) {
	n, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid id"})
		return 0, false
	}
	return uint(n), true
}

// NotFound writes a 404.
func NotFound(c *gin.Context, resource string) {
	c.JSON(http.StatusNotFound, gin.H{"error": resource + " not found"})
}

// DbError writes a 500 with the DB error message.
func DbError(c *gin.Context, err error) {
	c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
}

// ValidationError writes a 400.
func ValidationError(c *gin.Context, msg string) {
	c.JSON(http.StatusBadRequest, gin.H{"error": msg})
}

// Paginate reads optional query params skip/limit with sensible defaults.
func Paginate(c *gin.Context) (int, int) {
	skip, _ := strconv.Atoi(c.DefaultQuery("skip", "0"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "100"))
	if limit > 500 { limit = 500 }
	return skip, limit
}

// IsRecordNotFound checks if the GORM error means "no row".
func IsRecordNotFound(err error) bool {
	return err != nil && err == gorm.ErrRecordNotFound
}
