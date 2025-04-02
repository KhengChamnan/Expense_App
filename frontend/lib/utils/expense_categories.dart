import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class ExpenseCategories {
  static const List<ExpenseCategory> categories = [
    ExpenseCategory(
      name: 'Food',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    ExpenseCategory(
      name: 'Transport',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    ExpenseCategory(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.purple,
    ),
    ExpenseCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.pink,
    ),
    ExpenseCategory(
      name: 'Utilities',
      icon: Icons.lightbulb,
      color: Colors.amber,
    ),
    ExpenseCategory(
      name: 'Housing',
      icon: Icons.home,
      color: Colors.brown,
    ),
    ExpenseCategory(
      name: 'Health',
      icon: Icons.health_and_safety,
      color: Colors.red,
    ),
    ExpenseCategory(
      name: 'Education',
      icon: Icons.school,
      color: Colors.teal,
    ),
    ExpenseCategory(
      name: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];

  static ExpenseCategory? getCategoryByName(String name) {
    try {
      return categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  static List<String> getCategoryNames() {
    return categories.map((category) => category.name).toList();
  }
} 