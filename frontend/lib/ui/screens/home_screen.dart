import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../../widgets/expense_card.dart';
import '../../utils/expense_categories.dart';
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
  int _currentIndex = 0;

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
  
  // Group expenses by date
  Map<String, List<dynamic>> _groupExpensesByDate(List<dynamic> expenses) {
    final Map<String, List<dynamic>> grouped = {};
    
    for (var expense in expenses) {
      final date = expense.date.split('T')[0]; // Get YYYY-MM-DD format
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      
      grouped[date]!.add(expense);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _buildHomeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          ).then((_) => _refreshExpenses());
        },
        child: const Icon(Icons.add),
      ) : null,
    );
  }
  
  Widget _buildHomeScreen() {
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
                        margin: const EdgeInsets.all(15),
                        elevation: 2,
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
                      
                      // Expense list with date headers
                      Expanded(
                        child: _buildExpenseListWithDateHeaders(expensesList),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
  
  Widget _buildExpenseListWithDateHeaders(List<dynamic> expenses) {
    // Group expenses by date
    final groupedExpenses = _groupExpensesByDate(expenses);
    
    // Sort dates (keys) in descending order
    final sortedDates = groupedExpenses.keys.toList()
      ..sort((a, b) => b.compareTo(a));
      
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0), // Remove horizontal padding for slidable
      itemCount: sortedDates.length * 2, // Double the count for headers and expense groups
      itemBuilder: (context, index) {
        // Determine if this is a header (even index) or expense list (odd index)
        final isHeader = index % 2 == 0;
        final dateIndex = index ~/ 2;
        
        if (isHeader) {
          // This is a date header
          final dateStr = sortedDates[dateIndex];
          final dateObj = DateTime.parse(dateStr);
          final formattedDate = DateFormat('EEEE, d MMM').format(dateObj);
          final dailyTotal = groupedExpenses[dateStr]!
              .fold(0.0, (sum, expense) => sum + expense.amount);
          
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 8, top: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  NumberFormat.currency(locale: 'en_US', symbol: '\$').format(dailyTotal),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: dailyTotal > 0 ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          );
        } else {
          // This is the list of expenses for a date
          final dateStr = sortedDates[dateIndex];
          final expensesForDate = groupedExpenses[dateStr]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: expensesForDate.map<Widget>((expense) {
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
            }).toList(),
          );
        }
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