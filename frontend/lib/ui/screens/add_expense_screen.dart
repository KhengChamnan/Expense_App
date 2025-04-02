import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/expense_categories.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({Key? key, this.expense}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = ExpenseCategories.getCategoryNames().first;
  DateTime _selectedDate = DateTime.now();
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.expense != null;
    if (_isEdit) {
      _amountController.text = widget.expense!.amount.toString();
      _selectedCategory = widget.expense!.category;
      _selectedDate = DateTime.parse(widget.expense!.date);
      _notesController.text = widget.expense!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to add expenses'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text);
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final notes = _notesController.text.isEmpty ? null : _notesController.text;

      bool success;
      if (_isEdit) {
        // Create a copy of the existing expense with updated values
        final updatedExpense = Expense(
          id: widget.expense!.id is String ? int.parse(widget.expense!.id.toString()) : widget.expense!.id,
          userId: widget.expense!.userId is String ? int.parse(widget.expense!.userId.toString()) : widget.expense!.userId,
          amount: amount,
          category: _selectedCategory,
          date: formattedDate,
          notes: notes,
          createdAt: widget.expense!.createdAt,
        );
        
        success = await expenseProvider.updateExpense(updatedExpense);
      } else {
        // Create a new expense
        final newExpense = Expense(
          userId: user.id is String ? int.parse(user.id.toString()) : user.id,
          amount: amount,
          category: _selectedCategory,
          date: formattedDate,
          notes: notes,
        );
        
        success = await expenseProvider.createExpense(newExpense);
      }

      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, _) {
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount Field
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateAmount,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: ExpenseCategories.getCategoryNames().map((category) {
                      final categoryInfo = ExpenseCategories.getCategoryByName(category);
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              categoryInfo?.icon ?? Icons.circle,
                              color: categoryInfo?.color ?? Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                    validator: Validators.validateCategory,
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Picker
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('MMMM dd, yyyy').format(_selectedDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: expenseProvider.isLoading ? null : _saveExpense,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: expenseProvider.isLoading
                        ? const SpinKitThreeBounce(
                            color: Colors.white,
                            size: 24,
                          )
                        : Text(
                            _isEdit ? 'Update Expense' : 'Add Expense',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 