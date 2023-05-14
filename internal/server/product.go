package server

import (
	"net/http"

	"github.com/bindian0509/microservices-with-golang/internal/db_errors"
	"github.com/bindian0509/microservices-with-golang/internal/models"
	"github.com/labstack/echo/v4"
)


func (s *EchoServer) GetAllProducts(ctx echo.Context) error {
	vendorID := ctx.QueryParam("vendorId")
	products, err := s.DB.GetAllProducts(ctx.Request().Context(), vendorID)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, err)
	}
	return ctx.JSON(http.StatusOK, products)
}

func (s *EchoServer) AddProduct(ctx echo.Context) error {
	product := new(models.Product)
	if err := ctx.Bind(product); err != nil {
		return ctx.JSON(http.StatusUnsupportedMediaType, err)
	}
	product, err := s.DB.AddProduct(ctx.Request().Context(), product)
	if err != nil {
		switch err.(type) {
		case *db_errors.ConflictError:
			return ctx.JSON(http.StatusConflict, err)
		default:
			return ctx.JSON(http.StatusInternalServerError, err)
		}
	}
	return ctx.JSON(http.StatusCreated, product)
}

func (s *EchoServer) GetProductById(ctx echo.Context) error {
	ID := ctx.Param("id")
	product, err := s.DB.GetProductById(ctx.Request().Context(), ID)
	if err != nil {
		switch err.(type) {
		case *db_errors.NotFoundError:
			return ctx.JSON(http.StatusNotFound, err)
		default:
			return ctx.JSON(http.StatusInternalServerError, err)
		}
	}
	return ctx.JSON(http.StatusOK, product)
}



func (s *EchoServer) UpdateProduct(ctx echo.Context) error {
	ID := ctx.Param("id")
	product := new(models.Product)
	if err := ctx.Bind(product); err != nil {
		return ctx.JSON(http.StatusUnsupportedMediaType, err)
	}
	if ID != product.ProductID {
		return ctx.JSON(http.StatusBadRequest, "product_id on path doesn't match product_id on body")
	}

	product, err := s.DB.UpdateProduct(ctx.Request().Context(), product)
	if err != nil {
		switch err.(type) {
		case *db_errors.NotFoundError:
			return ctx.JSON(http.StatusNotFound, err)
		case *db_errors.ConflictError:
			return ctx.JSON(http.StatusConflict, err)
		default:
			return ctx.JSON(http.StatusInternalServerError, err)
		}
	}
	return ctx.JSON(http.StatusOK, product)
}
