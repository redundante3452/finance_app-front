import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:finance_app/features/accounts/screens/accounts_screen.dart';
import 'package:finance_app/features/categories/screens/categories_screen.dart';
import 'package:finance_app/features/transactions/models/transaction_model.dart';
import 'package:finance_app/features/transactions/screens/create_transaction_screen.dart';
import 'package:finance_app/features/transactions/screens/transaction_detail_screen.dart';
import 'package:finance_app/features/transactions/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('TRANSACCIONES'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.background,
              ),
              child: Center(
                child: Text(
                  'FINANCE APP',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list, color: AppColors.textPrimary),
              title: const Text('Transacciones', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: AppColors.textPrimary),
              title: const Text('Cuentas', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category, color: AppColors.textPrimary),
              title: const Text('Categorías', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoriesScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: AppColors.textDim.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No hay transacciones aún',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textDim,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms).scale(),
            );
          }

          // Group transactions by date
          final groupedTransactions = <String, List<TransactionModel>>{};
          for (var t in transactions) {
            final dateKey = DateFormat('yyyy-MM-dd').format(t.date);
            if (!groupedTransactions.containsKey(dateKey)) {
              groupedTransactions[dateKey] = [];
            }
            groupedTransactions[dateKey]!.add(t);
          }

          final sortedKeys = groupedTransactions.keys.toList()
            ..sort((a, b) => b.compareTo(a)); // Newest first

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: sortedKeys.length,
            itemBuilder: (context, sectionIndex) {
              final dateKey = sortedKeys[sectionIndex];
              final date = DateTime.parse(dateKey);
              final dayTransactions = groupedTransactions[dateKey]!;
              
              String headerText;
              final now = DateTime.now();
              if (date.year == now.year && date.month == now.month && date.day == now.day) {
                headerText = 'Hoy';
              } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
                headerText = 'Ayer';
              } else {
                headerText = DateFormat('EEEE d, MMMM', 'es').format(date);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Text(
                      headerText.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ...dayTransactions.map((transaction) {
                    return Dismissible(
                      key: Key(transaction.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text('Eliminar Transacción'),
                            content: const Text('¿Estás seguro? Esta acción actualizará el balance de tu cuenta.'),
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
                      },
                      onDismissed: (direction) async {
                        try {
                          await ref.read(transactionServiceProvider).deleteTransaction(transaction.id);
                          
                          // Refresh both lists to update UI and Balance
                          ref.invalidate(transactionsProvider);
                          ref.invalidate(accountsProvider);
                          
                          if (context.mounted) {
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
                            // Refresh to bring back the item if delete failed
                            ref.refresh(transactionsProvider);
                          }
                        }
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailScreen(transaction: transaction),
                            ),
                          );
                        },
                        child: TransactionItem(transaction: transaction)
                            .animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
                      ),
                    );
                  }).toList(),
                ],
              ).animate().fadeIn(delay: (100 * sectionIndex).ms);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar transacciones',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(transactionsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Lift above floating nav bar
        child: FloatingActionButton(
          heroTag: 'transaction_fab',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTransactionScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.background),
        ).animate().scale(delay: 500.ms, duration: 400.ms),
      ),
    );
  }
}
