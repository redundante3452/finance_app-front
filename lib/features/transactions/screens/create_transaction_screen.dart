import 'package:finance_app/core/auth/auth_provider.dart';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finance_app/features/transactions/models/transaction_model.dart';

class CreateTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;
  const CreateTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends ConsumerState<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _type;
  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction?.amount.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.transaction?.description ?? '');
    _type = widget.transaction?.type ?? 'EXPENSE';
    _selectedAccountId = widget.transaction?.accountId;
    _selectedCategoryId = widget.transaction?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = double.parse(_amountController.text);
        final transactionData = {
          'amount': amount,
          'type': _type,
          'description': _descriptionController.text,
          'accountId': _selectedAccountId,
          'categoryId': _selectedCategoryId,
          'date': widget.transaction?.date.toIso8601String() ?? DateTime.now().toIso8601String(),
        };

        if (widget.transaction != null) {
          await ref.read(transactionServiceProvider).updateTransaction(widget.transaction!.id, transactionData);
        } else {
          await ref.read(transactionServiceProvider).createTransaction(transactionData);
        }
        
        // Refresh lists
        ref.invalidate(transactionsProvider);
        ref.invalidate(accountsProvider); 
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.transaction != null ? 'Transacción actualizada' : 'Transacción creada'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction != null ? 'EDITAR TRANSACCIÓN' : 'NUEVA TRANSACCIÓN'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Toggle
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'INGRESO',
                      isSelected: _type == 'INCOME',
                      color: AppColors.success,
                      onTap: () => setState(() {
                        _type = 'INCOME';
                        _selectedCategoryId = null; 
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TypeButton(
                      label: 'GASTO',
                      isSelected: _type == 'EXPENSE',
                      color: AppColors.error,
                      onTap: () => setState(() {
                        _type = 'EXPENSE';
                        _selectedCategoryId = null; 
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: Theme.of(context).textTheme.displayMedium,
                decoration: const InputDecoration(
                  labelText: 'MONTO',
                  prefixText: '\$ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa un monto';
                  if (double.tryParse(value) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Dropdown
              accountsAsync.when(
                data: (accounts) => DropdownButtonFormField<String>(
                  value: _selectedAccountId,
                  decoration: const InputDecoration(labelText: 'CUENTA'),
                  dropdownColor: AppColors.surface,
                  items: accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name, style: const TextStyle(color: AppColors.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedAccountId = value),
                  validator: (value) => value == null ? 'Selecciona una cuenta' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error cargando cuentas: $err', style: const TextStyle(color: AppColors.error)),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              categoriesAsync.when(
                data: (categories) {
                  // Filter categories by type
                  final filteredCategories = categories.where((c) => c.type == _type).toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'CATEGORÍA'),
                    dropdownColor: AppColors.surface,
                    items: filteredCategories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name, style: const TextStyle(color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategoryId = value),
                    validator: (value) => value == null ? 'Selecciona una categoría' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error cargando categorías: $err', style: const TextStyle(color: AppColors.error)),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'DESCRIPCIÓN',
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                child: Text(widget.transaction != null ? 'ACTUALIZAR' : 'GUARDAR TRANSACCIÓN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.surfaceLight,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
