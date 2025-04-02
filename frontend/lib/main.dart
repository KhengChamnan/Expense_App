import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/api/auth_api_repository.dart';
import 'data/repository/expense_repository.dart';
import 'data/repository/api/expense_api_repository.dart';
import 'ui/providers/auth_provider.dart';
import 'ui/providers/expense_provider.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/auth_wrapper.dart';

void main() {
  // Create repositories
  final AuthRepository authRepository = AuthApiRepository();
  final ExpenseRepository expenseRepository = ExpenseApiRepository(authRepository);
  
  runApp(
    MultiProvider(
      providers: [
        // State providers
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(repository: expenseRepository),
        ),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

