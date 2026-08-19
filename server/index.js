const express = require('express');
const app = express();
const cors = require('cors');
    
//middlewares
app.use(cors());
app.use(express.json());

//starting server 
app.listen(5000, () => {
  console.log(`Server is running on port 5000`);
});


