import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/features/transactions/models/transaction_model.dart';
import 'package:finance_app/features/transactions/screens/transaction_detail_screen.dart';
import 'package:finance_app/features/transactions/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class CategoryTransactionsScreen extends StatelessWidget {
  final String categoryName;
  final List<TransactionModel> transactions;

  const CategoryTransactionsScreen({
    super.key,
    required this.categoryName,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = transactions.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );

    // Sort by date descending
    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName.toUpperCase()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header with Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Total Gastado',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.background,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.background,
                        fontSize: 32,
                      ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: sortedTransactions.length,
              itemBuilder: (context, index) {
                final transaction = sortedTransactions[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailScreen(transaction: transaction),
                      ),
                    );
                  },
                  child: TransactionItem(transaction: transaction)
                      .animate()
                      .fadeIn(delay: (50 * index).ms)
                      .slideX(begin: 0.1, end: 0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
