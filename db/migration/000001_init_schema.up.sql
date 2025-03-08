CREATE TABLE services (
  service_id UUID PRIMARY KEY,
  name VARCHAR UNIQUE,
  price NUMERIC(12,2)
);

ALTER TABLE services
ADD COLUMN created_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();

CREATE TABLE customers (
   customer_id UUID PRIMARY KEY,
   first_name VARCHAR,
   last_name VARCHAR,
   email VARCHAR,
   phone VARCHAR,
   address VARCHAR
);

CREATE TABLE vendors (
     vendor_id UUID PRIMARY KEY,
     name VARCHAR NOT NULL,
     contact VARCHAR,
     phone VARCHAR,
     email VARCHAR,
     address VARCHAR
);

CREATE TABLE products (
      product_id UUID PRIMARY KEY,
      name VARCHAR UNIQUE,
      price NUMERIC (12,2),
      vendor_id UUID NOT NULL,
      FOREIGN KEY (VENDOR_ID) references vendors(VENDOR_ID)
);
