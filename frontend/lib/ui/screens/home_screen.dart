import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../../widgets/expense_card.dart';
import '../../utils/expense_categories.dart';
import 'login_screen.dart';
import 'add_expense_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false)
          .loadExpensesByMonth(_selectedYear, _selectedMonth);
    });
  }

  Future<void> _refreshExpenses() async {
    await Provider.of<ExpenseProvider>(context, listen: false)
        .loadExpensesByMonth(_selectedYear, _selectedMonth);
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedYear = _selectedYear;
        int selectedMonth = _selectedMonth;

        return AlertDialog(
          title: const Text('Select Month'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 300,
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left),
                          onPressed: () {
                            setState(() {
                              selectedYear--;
                            });
                          },
                        ),
                        Text(
                          selectedYear.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_right),
                          onPressed: () {
                            setState(() {
                              selectedYear++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Month grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == selectedMonth;
                          final monthName = DateFormat('MMM').format(
                            DateTime(2022, month),
                          );

                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedMonth = month;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  monthName,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedYear = selectedYear;
                  _selectedMonth = selectedMonth;
                });
                Provider.of<ExpenseProvider>(context, listen: false)
                    .loadExpensesByMonth(_selectedYear, _selectedMonth);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(int expenseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ExpenseProvider>(context, listen: false)
                  .deleteExpense(expenseId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ExpenseProvider>(
      builder: (context, authProvider, expenseProvider, _) {
        if (expenseProvider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(expenseProvider.error!),
                backgroundColor: Colors.red,
              ),
            );
            expenseProvider.clearError();
          });
        }

        final monthName = DateFormat('MMMM').format(
          DateTime(_selectedYear, _selectedMonth),
        );

        // Check loading state
        if (expenseProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text('$monthName $_selectedYear'),
              centerTitle: true,
            ),
            body: const Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 50,
              ),
            ),
          );
        }

        // Get expenses list safely
        final expensesList = expenseProvider.expensesList;
        final hasExpenses = expensesList.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: _showMonthPicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$monthName $_selectedYear'),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: !hasExpenses
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses for $monthName $_selectedYear',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Expense'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddExpenseScreen(),
                            ),
                          ).then((_) => _refreshExpenses());
                        },
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshExpenses,
                  child: Column(
                    children: [
                      // Summary card
                      Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly Summary',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Expenses:'),
                                  Text(
                                    NumberFormat.currency(
                                      locale: 'en_US',
                                      symbol: '\$',
                                    ).format(expenseProvider.getTotalExpensesForMonth()),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Top Categories:'),
                              const SizedBox(height: 8),
                              _buildCategorySummary(expenseProvider),
                            ],
                          ),
                        ),
                      ),
                      // Expense list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: expensesList.length,
                          itemBuilder: (context, index) {
                            final expense = expensesList[index];
                            return ExpenseCard(
                              expense: expense,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddExpenseScreen(
                                      expense: expense,
                                    ),
                                  ),
                                ).then((_) => _refreshExpenses());
                              },
                              onDelete: () => _confirmDelete(expense.id!),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddExpenseScreen(),
                ),
              ).then((_) => _refreshExpenses());
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildCategorySummary(ExpenseProvider provider) {
    final categoryMap = provider.getExpensesByCategory();
    final total = provider.getTotalExpensesForMonth();
    
    if (categoryMap.isEmpty) {
      return const Text('No data available');
    }

    // Sort categories by amount (descending)
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Take top 3 categories
    final topCategories = sortedCategories.take(3).toList();

    return Column(
      children: topCategories.map((entry) {
        final category = ExpenseCategories.getCategoryByName(entry.key);
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: category?.color ?? Colors.grey,
                child: Icon(
                  category?.icon ?? Icons.attach_money,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.key),
              const Spacer(),
              Text('$percentage%'),
              const SizedBox(width: 8),
              Text(
                NumberFormat.currency(locale: 'en_US', symbol: '\$').format(entry.value),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 