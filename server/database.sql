create database crud_application;
create table todo(
    todo_id SERIAL PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);