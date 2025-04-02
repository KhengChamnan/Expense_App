import '../../models/expense.dart';

/// Data Transfer Object for Expense model
class ExpenseDTO {
  /// Convert a JSON map to an Expense object
  static Expense fromJson(Map<String, dynamic> json) {
    // Safely parse ID and userId to integers
    int? id;
    if (json['ID'] != null || json['id'] != null) {
      final rawId = json['ID'] ?? json['id'];
      id = rawId is int ? rawId : int.tryParse(rawId.toString());
    }
    
    int userId;
    final rawUserId = json['USER_ID'] ?? json['userId'];
    userId = rawUserId is int ? rawUserId : int.parse(rawUserId.toString());
    
    return Expense(
      id: id,
      userId: userId,
      amount: double.parse(json['AMOUNT']?.toString() ?? json['amount']?.toString() ?? '0'),
      category: json['CATEGORY'] ?? json['category'],
      date: json['DATE'] ?? json['date'],
      notes: json['NOTES'] ?? json['notes'],
      createdAt: json['CREATED_AT'] ?? json['createdAt'],
    );
  }

  /// Convert an Expense object to a JSON map
  static Map<String, dynamic> toJson(Expense expense) {
    return {
      'id': expense.id,
      'userId': expense.userId,
      'amount': expense.amount,
      'category': expense.category,
      'date': expense.date,
      'notes': expense.notes,
      'createdAt': expense.createdAt,
    };
  }
} 