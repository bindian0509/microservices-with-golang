package server

import (
	"net/http"

	"github.com/bindian0509/microservices-with-golang/internal/db_errors"
	"github.com/bindian0509/microservices-with-golang/internal/models"
	"github.com/labstack/echo/v4"
)


func (s *EchoServer) GetAllCustomers(ctx echo.Context) error {
	emailAddress := ctx.QueryParam("emailAddress")

	customers, err := s.DB.GetAllCustomers(ctx.Request().Context(), emailAddress)
	if err != nil {
		return ctx.JSON(http.StatusInternalServerError, err)
	}
	return ctx.JSON(http.StatusOK, customers)
}

func (s *EchoServer) AddCustomer(ctx echo.Context) error {
	customer := new(models.Customer)
	if err := ctx.Bind(customer); err != nil {
		return ctx.JSON(http.StatusUnsupportedMediaType, err)
	}
	customer, err := s.DB.AddCustomer(ctx.Request().Context(), customer)
	if err != nil {
		switch err.(type) {
		case *db_errors.ConflictError:
			return ctx.JSON(http.StatusConflict, err)
		default:
			return ctx.JSON(http.StatusInternalServerError, err)
		}
	}
	return ctx.JSON(http.StatusCreated, customer)
}
