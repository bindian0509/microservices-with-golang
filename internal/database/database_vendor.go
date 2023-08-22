package database

import (
	"context"

	"github.com/bindian0509/microservices-with-golang/internal/models"
)

func (c Client) GetAllVendors(ctx context.Context) ([]models.Vendor, error) {
	var vendors []models.Vendor
	result := c.DB.WithContext(ctx).
		Find(&vendors)
	return vendors, result.Error
}
