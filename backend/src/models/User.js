const db = require('../db/db');
const bcrypt = require('bcrypt');

class User {
  static async findByUsername(username) {
    return new Promise((resolve, reject) => {
      db.get('SELECT * FROM USERS WHERE USERNAME = ?', [username], (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row);
        }
      });
    });
  }

  static async findByEmail(email) {
    return new Promise((resolve, reject) => {
      db.get('SELECT * FROM USERS WHERE EMAIL = ?', [email], (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row);
        }
      });
    });
  }

  static async findById(id) {
    return new Promise((resolve, reject) => {
      db.get('SELECT ID, USERNAME, EMAIL, CREATED_AT FROM USERS WHERE ID = ?', [id], (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row);
        }
      });
    });
  }

  static async create(username, email, password) {
    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    return new Promise((resolve, reject) => {
      db.run(
        'INSERT INTO USERS (USERNAME, EMAIL, HASHED_PASS) VALUES (?, ?, ?)',
        [username, email, hashedPassword],
        function(err) {
          if (err) {
            reject(err);
          } else {
            resolve({
              id: this.lastID,
              username,
              email
            });
          }
        }
      );
    });
  }

  static async validatePassword(user, password) {
    return await bcrypt.compare(password, user.HASHED_PASS);
  }
}

module.exports = User; 