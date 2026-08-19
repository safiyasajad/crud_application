const express = require('express');
const app = express();
const cors = require('cors');
const pool = require('./db');

//middlewares
app.use(cors());
app.use(express.json());

//ROUTES//

//create a todo 
//get all todos
//get a todo
//update a todo
//delete a todo

//starting server 
app.listen(5000, () => {
  console.log(`Server is running on port 5000`);
});


