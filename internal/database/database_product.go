package database

import (
	"context"

	"github.com/bindian0509/microservices-with-golang/internal/models"
)

func (c Client) GetAllProducts(ctx context.Context, VendorID string) ([]models.Product, error) {
	var products []models.Product
	result := c.DB.WithContext(ctx).
		Where(models.Product{VendorID: VendorID}).
		Find(&products)
	return products, result.Error
}
