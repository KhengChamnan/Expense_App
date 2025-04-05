import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/expense_categories.dart';

class SpendingCalendarScreen extends StatefulWidget {
  const SpendingCalendarScreen({Key? key}) : super(key: key);

  @override
  State<SpendingCalendarScreen> createState() => _SpendingCalendarScreenState();
}

class _SpendingCalendarScreenState extends State<SpendingCalendarScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        final monthName = DateFormat('MMMM').format(
          DateTime(_selectedYear, _selectedMonth),
        );

        final expensesList = expenseProvider.expensesList;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
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
          body: Column(
            children: [
              // Title and explanation
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Monthly Spending Calendar',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Color intensity represents spending amount. Tap a day to see details.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Month summary card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 240,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side - Text content
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Monthly Expenses',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    NumberFormat.compactCurrency(
                                      decimalDigits: 1,
                                      symbol: '\$',
                                    ).format(expenseProvider.getTotalExpensesForMonth()),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              // Legend items
                              ..._buildPieChartLegend(expenseProvider),
                            ],
                          ),
                        ),
                        // Right side - Pie chart
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: _buildPieChart(expenseProvider),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Daily calendar view
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RefreshIndicator(
                    onRefresh: _refreshExpenses,
                    child: _buildCalendarGrid(expensesList),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getDaysWithExpenses(List<dynamic> expenses) {
    final Set<int> daysWithExpenses = {};
    
    for (var expense in expenses) {
      final expenseDate = DateTime.parse(expense.date);
      // Only include expenses from the selected month
      if (expenseDate.month == _selectedMonth && expenseDate.year == _selectedYear) {
        daysWithExpenses.add(expenseDate.day);
      }
    }
    
    return daysWithExpenses.length;
  }

  Widget _buildCalendarGrid(List<dynamic> expenses) {
    // Get the number of days in the selected month
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    
    // Get the day of week for the first day (0 = Sunday, 1 = Monday, etc.)
    final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // Adjust to make Sunday 0
    
    // Create a map to store daily totals
    final Map<int, double> dailyTotals = {};
    
    // Initialize all days with zero
    for (int day = 1; day <= daysInMonth; day++) {
      dailyTotals[day] = 0;
    }
    
    // Calculate totals for days with expenses
    for (var expense in expenses) {
      final expenseDate = DateTime.parse(expense.date);
      // Only include expenses from the selected month
      if (expenseDate.month == _selectedMonth && expenseDate.year == _selectedYear) {
        final day = expenseDate.day;
        dailyTotals[day] = (dailyTotals[day] ?? 0) + expense.amount;
      }
    }
    
    // Find the maximum daily total for color scaling
    final maxAmount = dailyTotals.values.isEmpty ? 0.0 : dailyTotals.values.reduce((max, value) => max > value ? max : value);
    
    // Add empty cells for days before the first day of the month
    final totalCells = firstWeekday + daysInMonth;
    
    // Show the day names (Sun, Mon, etc) at the top
    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      children: [
        // Day names row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayNames.map((name) => 
            Expanded(
              child: Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          ).toList(),
        ),
        const SizedBox(height: 8),
        
        // Calendar grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              // Empty cells before the first day of the month
              if (index < firstWeekday) {
                return Container(color: Colors.transparent);
              }
              
              final day = index - firstWeekday + 1;
              final amount = dailyTotals[day] ?? 0;
              
              // Calculate color intensity based on amount relative to max
              final colorIntensity = maxAmount > 0 ? (amount / maxAmount) : 0;
              
              return InkWell(
                onTap: () {
                  // Handle tap on a day with expenses
                  if (amount > 0) {
                    _showDayExpensesDialog(day, amount);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: amount > 0 
                      ? Colors.green.withOpacity(0.2 + (colorIntensity * 0.8))
                      : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: amount > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                      if (amount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '\$${amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDayExpensesDialog(int day, double amount) {
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final expensesForDay = expenseProvider.expensesList.where((expense) {
      final expenseDate = DateTime.parse(expense.date);
      return expenseDate.day == day && 
             expenseDate.month == _selectedMonth && 
             expenseDate.year == _selectedYear;
    }).toList();
    
    final date = DateTime(_selectedYear, _selectedMonth, day);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Total: '),
                  Text(
                    NumberFormat.currency(locale: 'en_US', symbol: '\$').format(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Expenses:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: expensesForDay.length,
                  itemBuilder: (context, index) {
                    final expense = expensesForDay[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.2),
                        child: const Icon(Icons.receipt, color: Colors.blue),
                      ),
                      title: Text(expense.category),
                      subtitle: expense.notes != null && expense.notes!.isNotEmpty 
                        ? Text(expense.notes!) 
                        : null,
                      trailing: Text(
                        NumberFormat.currency(locale: 'en_US', symbol: '\$').format(expense.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(ExpenseProvider provider) {
    final categoryMap = provider.getExpensesByCategory();
    final total = provider.getTotalExpensesForMonth();
    
    if (categoryMap.isEmpty || total <= 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'No data',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Sort categories by amount
    final List<MapEntry<String, double>> sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Prepare pie chart sections
    List<PieChartSectionData> sections = [];
    
    // Get top categories (max 4)
    final topCategories = sortedCategories.take(4).toList();
    
    // If there are more categories, add an "Other" section
    double otherAmount = 0;
    if (sortedCategories.length > 4) {
      for (var i = 4; i < sortedCategories.length; i++) {
        otherAmount += sortedCategories[i].value;
      }
    }
    
    // Define colors for sections
    final List<Color> colors = [
      Colors.red.shade400,
      Colors.amber.shade400,
      Colors.green.shade400,
      Colors.blue.shade400,
      Colors.purple.shade400,
    ];
    
    // Add top category sections
    for (var i = 0; i < topCategories.length; i++) {
      final category = ExpenseCategories.getCategoryByName(topCategories[i].key);
      final Color color = category?.color ?? colors[i % colors.length];
      final double value = topCategories[i].value;
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: value,
          title: '',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    // Add "Other" section if needed
    if (otherAmount > 0) {
      sections.add(
        PieChartSectionData(
          color: colors.last,
          value: otherAmount,
          title: '',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 30,
            sections: sections,
            startDegreeOffset: 270,
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildPieChartLegend(ExpenseProvider provider) {
    final categoryMap = provider.getExpensesByCategory();
    final total = provider.getTotalExpensesForMonth();
    
    if (categoryMap.isEmpty) {
      return [
        Text(
          'No categories',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ];
    }
    
    // Sort categories by amount
    final List<MapEntry<String, double>> sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Get top categories (max 4)
    final topCategories = sortedCategories.take(4).toList();
    
    // Calculate other amount if needed
    double otherAmount = 0;
    if (sortedCategories.length > 4) {
      for (var i = 4; i < sortedCategories.length; i++) {
        otherAmount += sortedCategories[i].value;
      }
    }
    
    // Define colors for sections
    final List<Color> colors = [
      Colors.red.shade400,
      Colors.amber.shade400,
      Colors.green.shade400,
      Colors.blue.shade400,
      Colors.purple.shade400,
    ];
    
    List<Widget> legendItems = [];
    
    // Add top category legends
    for (var i = 0; i < topCategories.length; i++) {
      final item = topCategories[i];
      final category = ExpenseCategories.getCategoryByName(item.key);
      final Color color = category?.color ?? colors[i % colors.length];
      
      legendItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.key,
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Text(
                '\$${item.value.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Add "Other" legend if needed
    if (otherAmount > 0) {
      legendItems.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.last,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Other',
                style: TextStyle(fontSize: 12),
              ),
              const Spacer(),
              Text(
                '\$${otherAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return legendItems;
  }
} 