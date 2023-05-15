package server

import (
	"net/http"

	"github.com/bindian0509/microservices-with-golang/internal/db_errors"
	"github.com/bindian0509/microservices-with-golang/internal/models"
	"github.com/labstack/echo/v4"
)

func (s *EchoServer) GetAllVendors(ctx echo.Context) error {
	vendors, err := s.DB.GetAllVendors(ctx.Request().Context())
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, err)
	}
	return ctx.JSON(http.StatusOK, vendors)
}

func (s *EchoServer) AddVendor(ctx echo.Context) error {
	vendor := new(models.Vendor)
	if err := ctx.Bind(vendor); err != nil {
		return ctx.JSON(http.StatusUnsupportedMediaType, err)
	}
	vendor, err := s.DB.AddVendor(ctx.Request().Context(), vendor)
	if err != nil {
		switch err.(type) {
		case *db_errors.ConflictError:
			return ctx.JSON(http.StatusConflict, err)
		default:
			return ctx.JSON(http.StatusInternalServerError, err)
		}
	}
	return ctx.JSON(http.StatusCreated, vendor)
}

func (s *EchoServer) GetVendorById(ctx echo.Context) error {
	ID := ctx.Param("id")
	vendor, err := s.DB.GetVendorById(ctx.Request().Context(), ID)
	if err != nil {
		switch err.(type) {
		case *db_errors.NotFoundError:
			return ctx.JSON(http.StatusNotFound, err)
		default:
			return ctx.JSON(http.StatusInternalServerError, err)
		}
	}
	return ctx.JSON(http.StatusOK, vendor)
}


func (s *EchoServer) UpdateVendor(ctx echo.Context) error {
	ID := ctx.Param("id")
	vendor := new(models.Vendor)
	if err := ctx.Bind(vendor); err != nil {
		return ctx.JSON(http.StatusUnsupportedMediaType, err)
	}
	if ID != vendor.VendorID {
		return ctx.JSON(http.StatusBadRequest, "vendor_id on path doesn't match vendor_id on body")
	}

	vendor, err := s.DB.UpdateVendor(ctx.Request().Context(), vendor)
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
	return ctx.JSON(http.StatusOK, vendor)
}
