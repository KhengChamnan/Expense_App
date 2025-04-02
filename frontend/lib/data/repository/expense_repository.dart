import '../../models/expense.dart';

abstract class ExpenseRepository {
  /// Get all expenses for the current user
  Future<Map<String, dynamic>> getAllExpenses();
  
  /// Get expenses for a specific month
  Future<Map<String, dynamic>> getExpensesByMonth(int year, int month);
  
  /// Get a specific expense by ID
  Future<Map<String, dynamic>> getExpenseById(int id);
  
  /// Create a new expense
  Future<Map<String, dynamic>> createExpense(Expense expense);
  
  /// Update an existing expense
  Future<Map<String, dynamic>> updateExpense(Expense expense);
  
  /// Delete an expense
  Future<Map<String, dynamic>> deleteExpense(int id);
} 