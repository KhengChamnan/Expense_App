import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/expense.dart';
import '../utils/expense_categories.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseCard({
    Key? key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ExpenseCategory? category = ExpenseCategories.getCategoryByName(expense.category);
    
    // Format amount with separate whole and decimal parts
    final String amountStr = expense.amount.toString();
    final List<String> parts = amountStr.contains('.')
        ? amountStr.split('.')
        : [amountStr, '00'];
    final String wholeAmount = parts[0];
    final String decimalAmount = parts[1].padRight(2, '0').substring(0, 2);

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: InkWell(
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: category?.color ?? Colors.grey,
              child: Icon(
                category?.icon ?? Icons.attach_money,
                color: Colors.white,
              ),
            ),
            title: Row(
              children: [
                Text(
                  expense.category,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$wholeAmount,$decimalAmount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            subtitle: expense.notes != null && expense.notes!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Note: ${expense.notes}',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : null,
          ),
        ),
      ),
    );
  }
} 