import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../data/repository/expense_repository.dart';
import '../providers/async_value.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;
  
  // State for expenses list
  AsyncValue<List<Expense>> _expenses = AsyncValue.loading();
  // State for current expense (when viewing details)
  AsyncValue<Expense?> _currentExpense = AsyncValue.success(null);
  String? _error;
  
  // Simplified constructor with direct repository injection
  ExpenseProvider({required ExpenseRepository repository}) 
      : _repository = repository;

  // Getters
  AsyncValue<List<Expense>> get expenses => _expenses;
  AsyncValue<Expense?> get currentExpense => _currentExpense;
  bool get isLoading => _expenses.state == AsyncValueState.loading || 
                        _currentExpense.state == AsyncValueState.loading;
  String? get error => _error;
  List<Expense> get expensesList => _expenses.data ?? [];

  // Load all expenses
  Future<void> loadExpenses() async {
    _expenses = AsyncValue.loading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getAllExpenses();
      if (result['success']) {
        _expenses = AsyncValue.success(result['expenses']);
      } else {
        _error = result['message'];
        _expenses = AsyncValue.error(_error ?? 'Failed to load expenses');
      }
    } catch (e) {
      _error = 'Failed to load expenses: $e';
      _expenses = AsyncValue.error(e);
    } finally {
      notifyListeners();
    }
  }

  // Load expenses for a specific month
  Future<void> loadExpensesByMonth(int year, int month) async {
    _expenses = AsyncValue.loading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getExpensesByMonth(year, month);
      if (result['success']) {
        _expenses = AsyncValue.success(result['expenses']);
      } else {
        _error = result['message'];
        _expenses = AsyncValue.error(_error ?? 'Failed to load expenses');
      }
    } catch (e) {
      _error = 'Failed to load expenses: $e';
      _expenses = AsyncValue.error(e);
    } finally {
      notifyListeners();
    }
  }

  // Get expense by id
  Future<void> getExpenseById(int id) async {
    _currentExpense = AsyncValue.loading();
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getExpenseById(id);
      if (result['success']) {
        _currentExpense = AsyncValue.success(result['expense']);
      } else {
        _error = result['message'];
        _currentExpense = AsyncValue.error(_error ?? 'Failed to get expense');
      }
    } catch (e) {
      _error = 'Failed to get expense: $e';
      _currentExpense = AsyncValue.error(e);
    } finally {
      notifyListeners();
    }
  }

  // Create a new expense
  Future<bool> createExpense(Expense expense) async {
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.createExpense(expense);
      if (result['success']) {
        await loadExpenses(); // Reload the expenses list
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to create expense: $e';
      notifyListeners();
      return false;
    }
  }

  // Update an expense
  Future<bool> updateExpense(Expense expense) async {
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.updateExpense(expense);
      if (result['success']) {
        await loadExpenses(); // Reload the expenses list
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update expense: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete an expense
  Future<bool> deleteExpense(int id) async {
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.deleteExpense(id);
      if (result['success']) {
        await loadExpenses(); // Reload the expenses list
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get total expenses for selected month
  double getTotalExpensesForMonth() {
    if (_expenses.data == null) return 0;
    double total = 0;
    for (var expense in _expenses.data!) {
      total += expense.amount;
    }
    return total;
  }

  // Get expenses grouped by category
  Map<String, double> getExpensesByCategory() {
    final categoryMap = <String, double>{};
    for (final expense in _expenses.data ?? []) {
      if (categoryMap.containsKey(expense.category)) {
        categoryMap[expense.category] = (categoryMap[expense.category] ?? 0) + expense.amount;
      } else {
        categoryMap[expense.category] = expense.amount;
      }
    }
    return categoryMap;
  }
} 