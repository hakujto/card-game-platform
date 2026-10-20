package handler

import (
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// ParseID extracts and validates the :id path param.
func ParseID(c *fiber.Ctx) (uint, bool) {
	n, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid id"})
		return 0, false
	}
	return uint(n), true
}

// NotFound writes a 404.
func NotFound(c *fiber.Ctx, resource string) error {
	return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": resource + " not found"})
}

// DbError writes a 500 with the DB error message.
func DbError(c *fiber.Ctx, err error) error {
	return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
}

// ValidationError writes a 400.
func ValidationError(c *fiber.Ctx, msg string) error {
	return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": msg})
}

// ConflictError writes a 409.
func ConflictError(c *fiber.Ctx, msg string) error {
	return c.Status(fiber.StatusConflict).JSON(fiber.Map{"error": msg})
}

// UnprocessableError writes a 422.
func UnprocessableError(c *fiber.Ctx, msg string) error {
	return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{"error": msg})
}

// Paginate reads optional query params skip/limit with sensible defaults.
func Paginate(c *fiber.Ctx) (int, int) {
	skip, _ := strconv.Atoi(c.Query("skip", "0"))
	limit, _ := strconv.Atoi(c.Query("limit", "100"))
	if limit > 500 { limit = 500 }
	return skip, limit
}

// IsRecordNotFound checks if the GORM error means "no row".
func IsRecordNotFound(err error) bool {
	return err != nil && err == gorm.ErrRecordNotFound
}

// IsUniqueViolation checks if the error is a SQLite unique constraint violation.
func IsUniqueViolation(err error) bool {
	return err != nil && strings.Contains(err.Error(), "UNIQUE constraint failed")
}
