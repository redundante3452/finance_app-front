import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:finance_app/features/accounts/models/account_model.dart';
import 'package:finance_app/features/accounts/screens/create_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

class AccountDetailScreen extends ConsumerWidget {
  final AccountModel account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    
    // Find the updated account in the list, or use the passed one as fallback
    final currentAccount = accountsAsync.value?.firstWhere(
      (a) => a.id == account.id,
      orElse: () => account,
    ) ?? account;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALLE DE CUENTA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
               await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateAccountScreen(account: currentAccount),
                ),
              );
              // Invalidate to force refresh
              ref.invalidate(accountsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Eliminar Cuenta'),
                  content: Text('¿Estás seguro de eliminar "${currentAccount.name}"?'),
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
                await ref.read(accountServiceProvider).deleteAccount(currentAccount.id);
                ref.invalidate(accountsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
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
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
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
                    currentAccount.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${currentAccount.balance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.background,
                          fontSize: 40,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentAccount.currency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details
            _DetailRow(label: 'Tipo', value: currentAccount.type),
            const Divider(color: AppColors.surfaceLight),
            if (currentAccount.createdAt != null)
              _DetailRow(
                label: 'Fecha de Creación',
                value: DateFormat('dd MMM yyyy').format(currentAccount.createdAt!),
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
