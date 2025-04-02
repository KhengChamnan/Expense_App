class Expense {
  final int? id;
  final int userId;
  final double amount;
  final String category;
  final String date;
  final String? notes;
  final String? createdAt;

  Expense({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.createdAt,
  });

  // Create a copy with updated fields
  Expense copyWith({
    int? id,
    int? userId,
    double? amount,
    String? category,
    String? date,
    String? notes,
    String? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 