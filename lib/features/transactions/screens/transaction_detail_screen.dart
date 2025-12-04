import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:finance_app/features/transactions/models/transaction_model.dart';
import 'package:finance_app/features/transactions/screens/create_transaction_screen.dart'; // We might reuse this or create EditTransactionScreen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final transactionsAsync = ref.watch(transactionsProvider);

    // Find the latest version of this transaction from the provider
    // This ensures that updates are reflected immediately
    final updatedTransaction = transactionsAsync.value?.firstWhere(
      (t) => t.id == transaction.id,
      orElse: () => transaction,
    ) ?? transaction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALLE'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTransactionScreen(transaction: updatedTransaction),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Eliminar Transacción'),
                  content: const Text('¿Estás seguro?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCELAR'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('ELIMINAR', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await ref.read(transactionServiceProvider).deleteTransaction(updatedTransaction.id);
                  ref.invalidate(transactionsProvider);
                  ref.invalidate(accountsProvider);
                  if (context.mounted) {
                    Navigator.pop(context); // Close detail screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transacción eliminada'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Amount
            Text(
              '${updatedTransaction.type == 'EXPENSE' ? '-' : '+'} \$${updatedTransaction.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: updatedTransaction.type == 'EXPENSE' ? AppColors.error : AppColors.success,
                    fontSize: 40,
                  ),
            ),
            const SizedBox(height: 32),

            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surfaceLight,
                  width: 2,
                ),
              ),
              child: Icon(
                updatedTransaction.type == 'EXPENSE' ? Icons.shopping_bag_outlined : Icons.attach_money,
                size: 48,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description / Category Name
            categoriesAsync.when(
              data: (categories) {
                // If categoryId is null or not found, we might want to show "Sin Categoría"
                final categoryName = updatedTransaction.categoryId != null 
                    ? categories.firstWhere((c) => c.id == updatedTransaction.categoryId, orElse: () => categories.first).name 
                    : 'Sin Categoría';
                
                return Text(
                  categoryName, 
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const Text('Error'),
            ),
            
            const SizedBox(height: 48),

            // Details List
            _DetailRow(
              label: 'Fecha',
              value: DateFormat('dd MMM yyyy, hh:mm a').format(updatedTransaction.date),
            ),
            const Divider(color: AppColors.surfaceLight),
            _DetailRow(
              label: 'Categoría',
              value: categoriesAsync.when(
                data: (categories) {
                  return updatedTransaction.categoryId != null 
                      ? categories.firstWhere((c) => c.id == updatedTransaction.categoryId, orElse: () => categories.first).name 
                      : 'Sin Categoría';
                },
                loading: () => 'Cargando...',
                error: (_, __) => 'Error',
              ),
            ),
             _DetailRow(
              label: 'Notas',
              value: (updatedTransaction.description != null && updatedTransaction.description!.isNotEmpty) 
                  ? updatedTransaction.description! 
                  : 'Sin notas',
            ),
            const Divider(color: AppColors.surfaceLight),
             accountsAsync.when(
              data: (accounts) {
                final account = accounts.firstWhere((a) => a.id == updatedTransaction.accountId, orElse: () => accounts.first);
                return _DetailRow(label: 'Cuenta', value: account.name);
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
