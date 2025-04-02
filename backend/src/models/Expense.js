const db = require('../db/db');

class Expense {
  static async create(userId, amount, category, date, notes = null) {
    return new Promise((resolve, reject) => {
      db.run(
        'INSERT INTO EXPENSE (USER_ID, AMOUNT, CATEGORY, DATE, NOTES) VALUES (?, ?, ?, ?, ?)',
        [userId, amount, category, date, notes],
        function(err) {
          if (err) {
            reject(err);
          } else {
            resolve({
              id: this.lastID,
              userId,
              amount,
              category,
              date,
              notes
            });
          }
        }
      );
    });
  }

  static async findById(id, userId) {
    return new Promise((resolve, reject) => {
      db.get(
        'SELECT * FROM EXPENSE WHERE ID = ? AND USER_ID = ?',
        [id, userId],
        (err, row) => {
          if (err) {
            reject(err);
          } else {
            resolve(row);
          }
        }
      );
    });
  }

  static async findAll(userId) {
    return new Promise((resolve, reject) => {
      db.all(
        'SELECT * FROM EXPENSE WHERE USER_ID = ? ORDER BY DATE DESC',
        [userId],
        (err, rows) => {
          if (err) {
            reject(err);
          } else {
            resolve(rows);
          }
        }
      );
    });
  }

  static async findByMonth(userId, year, month) {
    const startDate = `${year}-${month.toString().padStart(2, '0')}-01`;
    const endDate = `${year}-${month.toString().padStart(2, '0')}-31`;

    return new Promise((resolve, reject) => {
      db.all(
        'SELECT * FROM EXPENSE WHERE USER_ID = ? AND DATE BETWEEN ? AND ? ORDER BY DATE ASC',
        [userId, startDate, endDate],
        (err, rows) => {
          if (err) {
            reject(err);
          } else {
            resolve(rows);
          }
        }
      );
    });
  }

  static async update(id, userId, amount, category, date, notes = null) {
    return new Promise((resolve, reject) => {
      db.run(
        'UPDATE EXPENSE SET AMOUNT = ?, CATEGORY = ?, DATE = ?, NOTES = ? WHERE ID = ? AND USER_ID = ?',
        [amount, category, date, notes, id, userId],
        function(err) {
          if (err) {
            reject(err);
          } else {
            if (this.changes === 0) {
              reject(new Error('Expense not found or not authorized'));
            } else {
              resolve({
                id,
                userId,
                amount,
                category,
                date,
                notes
              });
            }
          }
        }
      );
    });
  }

  static async delete(id, userId) {
    return new Promise((resolve, reject) => {
      db.run(
        'DELETE FROM EXPENSE WHERE ID = ? AND USER_ID = ?',
        [id, userId],
        function(err) {
          if (err) {
            reject(err);
          } else {
            if (this.changes === 0) {
              reject(new Error('Expense not found or not authorized'));
            } else {
              resolve({ success: true });
            }
          }
        }
      );
    });
  }
}

module.exports = Expense; 