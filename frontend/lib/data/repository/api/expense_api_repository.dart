import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/expense.dart';
import '../../dto/expense_dto.dart';
import '../../network/api_constants.dart';
import '../auth_repository.dart';
import '../expense_repository.dart';

class ExpenseApiRepository implements ExpenseRepository {
  final AuthRepository _authRepository;
  
  ExpenseApiRepository(this._authRepository);

  @override
  Future<Map<String, dynamic>> getAllExpenses() async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConstants.expensesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final expenses = data.map((item) => ExpenseDTO.fromJson(item)).toList();
        return {
          'success': true,
          'expenses': expenses,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get expenses',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getExpensesByMonth(int year, int month) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConstants.expensesByMonthUrl(year, month)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final expenses = data.map((item) => ExpenseDTO.fromJson(item)).toList();
        return {
          'success': true,
          'expenses': expenses,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get expenses',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getExpenseById(int id) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConstants.expenseByIdUrl(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'expense': ExpenseDTO.fromJson(data),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get expense',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> createExpense(Expense expense) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConstants.expensesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': expense.amount,
          'category': expense.category,
          'date': expense.date,
          'notes': expense.notes,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'expense': ExpenseDTO.fromJson(data['expense']),
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to create expense',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> updateExpense(Expense expense) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      // Ensure ID is an integer before using it in URL
      int expenseId;
      if (expense.id == null) {
        return {
          'success': false,
          'message': 'Expense ID is required for update',
        };
      }
      
      // Convert ID to int if it's not already
      if (expense.id is String) {
        expenseId = int.parse(expense.id.toString());
      } else {
        expenseId = expense.id!;
      }

      final response = await http.put(
        Uri.parse(ApiConstants.expenseByIdUrl(expenseId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': expense.amount,
          'category': expense.category,
          'date': expense.date,
          'notes': expense.notes,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
          'expense': ExpenseDTO.fromJson(data['expense']),
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to update expense',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> deleteExpense(int id) async {
    try {
      final token = await _authRepository.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
        };
      }

      // Ensure ID is an integer
      int expenseId = id;

      final response = await http.delete(
        Uri.parse(ApiConstants.expenseByIdUrl(expenseId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to delete expense',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
} 