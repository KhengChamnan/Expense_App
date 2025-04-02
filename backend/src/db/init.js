const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');
const dotenv = require('dotenv');

dotenv.config();

const dbPath = process.env.DB_PATH || path.join(__dirname, 'database.sqlite');

// Ensure database directory exists
const dbDir = path.dirname(dbPath);
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const initDb = () => {
  const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
      console.error('Error opening database', err.message);
      return;
    }
    console.log('Connected to the SQLite database');

    // Enable foreign keys
    db.run('PRAGMA foreign_keys = ON');

    // Create USERS table
    db.run(`CREATE TABLE IF NOT EXISTS USERS (
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      USERNAME TEXT UNIQUE NOT NULL,
      EMAIL TEXT UNIQUE NOT NULL,
      HASHED_PASS TEXT NOT NULL,
      CREATED_AT DATETIME DEFAULT CURRENT_TIMESTAMP
    )`, (err) => {
      if (err) {
        console.error('Error creating USERS table', err.message);
      } else {
        console.log('USERS table created or already exists');
      }
    });

    // Create EXPENSE table
    db.run(`CREATE TABLE IF NOT EXISTS EXPENSE (
      ID INTEGER PRIMARY KEY AUTOINCREMENT,
      USER_ID INTEGER NOT NULL,
      AMOUNT REAL NOT NULL,
      CATEGORY TEXT NOT NULL,
      DATE TEXT NOT NULL,
      NOTES TEXT,
      CREATED_AT DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (USER_ID) REFERENCES USERS(ID) ON DELETE CASCADE
    )`, (err) => {
      if (err) {
        console.error('Error creating EXPENSE table', err.message);
      } else {
        console.log('EXPENSE table created or already exists');
      }
    });
  });

  return db;
};

module.exports = initDb; 