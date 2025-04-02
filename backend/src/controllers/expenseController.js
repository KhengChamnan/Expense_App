const Expense = require('../models/Expense');

const createExpense = async (req, res) => {
  try {
    const userId = req.user.id;
    const { amount, category, date, notes } = req.body;

    // Validate input
    if (!amount || !category || !date) {
      return res.status(400).json({ error: 'Amount, category, and date are required' });
    }

    // Validate amount is a number
    if (isNaN(parseFloat(amount))) {
      return res.status(400).json({ error: 'Amount must be a number' });
    }

    // Create expense
    const newExpense = await Expense.create(
      userId,
      parseFloat(amount),
      category,
      date,
      notes
    );

    res.status(201).json({
      message: 'Expense created successfully',
      expense: newExpense
    });
  } catch (error) {
    console.error('Create expense error:', error);
    res.status(500).json({ error: 'Failed to create expense' });
  }
};

const getAllExpenses = async (req, res) => {
  try {
    const userId = req.user.id;
    const expenses = await Expense.findAll(userId);

    res.json(expenses);
  } catch (error) {
    console.error('Get expenses error:', error);
    res.status(500).json({ error: 'Failed to get expenses' });
  }
};

const getExpenseById = async (req, res) => {
  try {
    const userId = req.user.id;
    const expenseId = req.params.id;

    const expense = await Expense.findById(expenseId, userId);

    if (!expense) {
      return res.status(404).json({ error: 'Expense not found' });
    }

    res.json(expense);
  } catch (error) {
    console.error('Get expense error:', error);
    res.status(500).json({ error: 'Failed to get expense' });
  }
};

const getExpensesByMonth = async (req, res) => {
  try {
    const userId = req.user.id;
    const { year, month } = req.params;

    // Validate year and month
    if (!year || !month || isNaN(parseInt(year)) || isNaN(parseInt(month))) {
      return res.status(400).json({ error: 'Valid year and month are required' });
    }

    const expenses = await Expense.findByMonth(
      userId,
      parseInt(year),
      parseInt(month)
    );

    res.json(expenses);
  } catch (error) {
    console.error('Get expenses by month error:', error);
    res.status(500).json({ error: 'Failed to get expenses by month' });
  }
};

const updateExpense = async (req, res) => {
  try {
    const userId = req.user.id;
    const expenseId = req.params.id;
    const { amount, category, date, notes } = req.body;

    // Validate input
    if (!amount || !category || !date) {
      return res.status(400).json({ error: 'Amount, category, and date are required' });
    }

    // Validate amount is a number
    if (isNaN(parseFloat(amount))) {
      return res.status(400).json({ error: 'Amount must be a number' });
    }

    // Update expense
    const updatedExpense = await Expense.update(
      expenseId,
      userId,
      parseFloat(amount),
      category,
      date,
      notes
    );

    res.json({
      message: 'Expense updated successfully',
      expense: updatedExpense
    });
  } catch (error) {
    console.error('Update expense error:', error);
    if (error.message === 'Expense not found or not authorized') {
      return res.status(404).json({ error: error.message });
    }
    res.status(500).json({ error: 'Failed to update expense' });
  }
};

const deleteExpense = async (req, res) => {
  try {
    const userId = req.user.id;
    const expenseId = req.params.id;

    await Expense.delete(expenseId, userId);

    res.json({ message: 'Expense deleted successfully' });
  } catch (error) {
    console.error('Delete expense error:', error);
    if (error.message === 'Expense not found or not authorized') {
      return res.status(404).json({ error: error.message });
    }
    res.status(500).json({ error: 'Failed to delete expense' });
  }
};

module.exports = {
  createExpense,
  getAllExpenses,
  getExpenseById,
  getExpensesByMonth,
  updateExpense,
  deleteExpense
}; 