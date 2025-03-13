-- name: CreateCustomer :one
INSERT INTO customers (
  first_name,
  last_name,
  email,
  phone,
  address
) VALUES (
  $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetCustomer :one
SELECT * FROM customers
WHERE customer_id = $1 LIMIT 1;

-- name: GetCustomerForUpdate :one
SELECT * FROM customers
WHERE customer_id = $1 LIMIT 1
FOR NO KEY UPDATE;

-- name: ListCustomers :many
SELECT * FROM customers
ORDER BY customer_id
LIMIT $1
OFFSET $2;

-- name: UpdateCustomerEmail :one
UPDATE customers
SET email = $2
WHERE customer_id = $1
RETURNING *;

-- name: DeleteCustomer :exec
DELETE FROM customers
WHERE customer_id = $1;
