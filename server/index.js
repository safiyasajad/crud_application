const express = require('express');
const cors = require('cors');
const pool = require('./db');
const app = express();

// Allows Flutter/web clients to call this API.
app.use(cors());

// Allows Express to read JSON request bodies.
app.use(express.json());

// CREATE - add a new contact to PostgreSQL.
app.post("/contacts", async (req, res) => {
  try {
    const { name, email, phone_number } = req.body;

    const newContact = await pool.query(
      "INSERT INTO contacts (name, email, phone_number) VALUES ($1, $2, $3) RETURNING *",
      [name, email, phone_number]
    );

    res.status(201).json(newContact.rows[0]);
  } catch (err) {
    console.error(err.message);
  }
});

// READ - get all contacts from PostgreSQL.
app.get("/contacts", async (req, res) => {
  try {
    const allContacts = await pool.query(
      "SELECT * FROM contacts"
    );

    res.json(allContacts.rows);

  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

// READ - get one contact by id.
app.get("/contacts/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const contact = await pool.query(
      "SELECT * FROM contacts WHERE contact_id = $1",
      [id]
    );

    if (contact.rows.length === 0) {
      return res.status(404).json({ error: "Contact not found" });
    }

    res.json(contact.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

// UPDATE 
app.put("/contacts/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email, phone_number } = req.body;

    const updatedContact = await pool.query(
      "UPDATE contacts SET name = $1, email = $2, phone_number = $3 WHERE contact_id = $4 RETURNING *",
      [name, email, phone_number, id]
    );

    if (updatedContact.rows.length === 0) {
      return res.status(404).json({ error: "Contact not found" });
    }

    res.json(updatedContact.rows[0]);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

// DELETE - remove a contact from PostgreSQL.
app.delete("/contacts/:id", async (req, res) => {
  try {
    const { id } = req.params;

    const deletedContact = await pool.query(
      "DELETE FROM contacts WHERE contact_id = $1 RETURNING *",
      [id]
    );

    if (deletedContact.rows.length === 0) {
      return res.status(404).json({ error: "Contact not found" });
    }

    res.json({ message: "Contact was deleted successfully" });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: err.message });
  }
});

app.listen(5000, () => {
  console.log("Server is running on port 5000");
});
