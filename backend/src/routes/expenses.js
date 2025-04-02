const express = require('express');
const {
  createExpense,
  getAllExpenses,
  getExpenseById,
  getExpensesByMonth,
  updateExpense,
  deleteExpense
} = require('../controllers/expenseController');
const authenticateToken = require('../middleware/auth');

const router = express.Router();

// All routes are protected with JWT
router.use(authenticateToken);

// Create a new expense
router.post('/', createExpense);

// Get all expenses for the logged-in user
router.get('/', getAllExpenses);

// Get a specific expense by id
router.get('/:id', getExpenseById);

// Get expenses for a specific month
router.get('/month/:year/:month', getExpensesByMonth);

// Update an expense
router.put('/:id', updateExpense);

// Delete an expense
router.delete('/:id', deleteExpense);

module.exports = router; 