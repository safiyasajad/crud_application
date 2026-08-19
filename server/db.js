const pool = require("pg").Pool;

const pool = new pool({
  user: "postgres",
  password: "root",
  host: "localhost",
  port: 5432,
  database: "crud_application"
});

module.exports = pool;