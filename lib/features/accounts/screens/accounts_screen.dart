import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:finance_app/features/accounts/screens/account_detail_screen.dart';
import 'package:finance_app/features/accounts/screens/create_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('MIS CUENTAS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(child: Text('No hay cuentas'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Added bottom padding for FAB/Nav
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Dismissible(
                key: Key(account.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text('Eliminar Cuenta', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20)),
                        content: Text('¿Estás seguro de que quieres eliminar la cuenta "${account.name}"? Esta acción no se puede deshacer.', style: Theme.of(context).textTheme.bodyMedium),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('CANCELAR', style: TextStyle(color: AppColors.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('ELIMINAR', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  await ref.read(accountServiceProvider).deleteAccount(account.id);
                  ref.invalidate(accountsProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cuenta "${account.name}" eliminada'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountDetailScreen(account: account),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: AppColors.surface.withOpacity(0.9),
                      shape: RoundedRectangleBorder( // Modern Rounded Look
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.secondary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded( // Fixed overflow
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                account.name, // Clean capitalization
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                overflow: TextOverflow.ellipsis, // Handle long names
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20), // Pill shape
                                ),
                                child: Text(
                                  account.currency,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16), // Spacing between name and balance
                        Text(
                          '\$${account.balance.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Lift above floating nav bar
        child: FloatingActionButton(
          heroTag: 'account_fab',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
            );
            if (result == true) {
              ref.invalidate(accountsProvider); // Refresh list
            }
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.background),
        ),
      ),
    );
  }
}
