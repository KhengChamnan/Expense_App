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

  // Create a new expense with optimistic updates
  Future<bool> createExpense(Expense expense) async {
    _error = null;
    
    // Optimistically add the expense to the list
    List<Expense> currentList = List<Expense>.from(_expenses.data ?? []);
    // Create a temporary ID (negative to avoid conflicts with server IDs)
    final tempExpense = expense.id == null 
        ? expense.copyWith(id: -DateTime.now().millisecondsSinceEpoch) 
        : expense;
    currentList.add(tempExpense);
    _expenses = AsyncValue.success(currentList);
    notifyListeners();

    try {
      final result = await _repository.createExpense(expense);
      if (result['success']) {
        // Load the updated list in the background without showing loading state
        _refreshInBackground();
        return true;
      } else {
        // Revert the optimistic update
        currentList.remove(tempExpense);
        _expenses = AsyncValue.success(currentList);
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Revert the optimistic update
      currentList.remove(tempExpense);
      _expenses = AsyncValue.success(currentList);
      _error = 'Failed to create expense: $e';
      notifyListeners();
      return false;
    }
  }

  // Update an expense with optimistic updates
  Future<bool> updateExpense(Expense expense) async {
    _error = null;
    
    // Keep a copy of the original list for rollback if needed
    final originalList = List<Expense>.from(_expenses.data ?? []);
    
    // Optimistically update the expense in the list
    List<Expense> currentList = List<Expense>.from(_expenses.data ?? []);
    final index = currentList.indexWhere((e) => e.id == expense.id);
    
    if (index != -1) {
      currentList[index] = expense;
      _expenses = AsyncValue.success(currentList);
      notifyListeners();
    }

    try {
      final result = await _repository.updateExpense(expense);
      if (result['success']) {
        // Load the updated list in the background without showing loading state
        _refreshInBackground();
        return true;
      } else {
        // Revert the optimistic update
        _expenses = AsyncValue.success(originalList);
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Revert the optimistic update
      _expenses = AsyncValue.success(originalList);
      _error = 'Failed to update expense: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete an expense with optimistic updates
  Future<bool> deleteExpense(int id) async {
    _error = null;
    
    // Keep a copy of the expense and the original list for rollback if needed
    final originalList = List<Expense>.from(_expenses.data ?? []);
    
    // Optimistically remove the expense from the list
    List<Expense> currentList = List<Expense>.from(_expenses.data ?? []);
    currentList.removeWhere((expense) => expense.id == id);
    _expenses = AsyncValue.success(currentList);
    notifyListeners();

    try {
      final result = await _repository.deleteExpense(id);
      if (result['success']) {
        // No need to reload - we've already removed it from the UI
        return true;
      } else {
        // Revert the optimistic update
        _expenses = AsyncValue.success(originalList);
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Revert the optimistic update
      _expenses = AsyncValue.success(originalList);
      _error = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }

  // Refresh data in the background without showing loading state
  Future<void> _refreshInBackground() async {
    try {
      // Get the current year and month from the first expense or use current date
      int year = _expenses.data?.isNotEmpty == true 
        ? DateTime.parse(_expenses.data!.first.date).year 
        : DateTime.now().year;
      int month = _expenses.data?.isNotEmpty == true 
        ? DateTime.parse(_expenses.data!.first.date).month 
        : DateTime.now().month;
      
      final result = await _repository.getExpensesByMonth(year, month);
      if (result['success']) {
        _expenses = AsyncValue.success(result['expenses']);
        notifyListeners();
      }
    } catch (e) {
      // Silent fail - we already have the optimistic update
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