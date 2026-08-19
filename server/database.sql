CREATE DATABASE crud_application;

CREATE TABLE contacts (
  contact_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  phone_number VARCHAR(30) NOT NULL
);
