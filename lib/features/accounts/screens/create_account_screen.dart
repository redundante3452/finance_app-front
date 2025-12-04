import 'package:finance_app/core/auth/auth_provider.dart';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:finance_app/features/accounts/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finance_app/features/accounts/models/account_model.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  final AccountModel? account;
  const CreateAccountScreen({super.key, this.account});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late String _selectedType;
  late String _selectedCurrency;

  final List<String> _accountTypes = ['EFECTIVO', 'BANCO', 'TARJETA', 'AHORRO'];
  final List<String> _currencies = ['COP', 'USD', 'EUR'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(text: widget.account?.balance.toString() ?? '0');
    _selectedType = widget.account?.type ?? 'EFECTIVO';
    _selectedCurrency = widget.account?.currency ?? 'COP';
    
    // Validate if type/currency from existing account is in list, otherwise default or add it
    if (!_accountTypes.contains(_selectedType)) _selectedType = _accountTypes.first;
    if (!_currencies.contains(_selectedCurrency)) _selectedCurrency = _currencies.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {

        final accountData = {
          'name': _nameController.text,
          'type': _selectedType,
          'balance': double.parse(_balanceController.text),
          'currency': _selectedCurrency,
        };

        final apiClient = ref.read(apiClientProvider);
        final accountService = AccountService(apiClient);

        if (widget.account != null) {
          await accountService.updateAccount(widget.account!.id, accountData);
        } else {
          await accountService.createAccount(accountData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.account != null ? 'Cuenta actualizada' : 'Cuenta creada exitosamente')),
          );
          Navigator.pop(context, true); // Return true to refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account != null ? 'EDITAR CUENTA' : 'NUEVA CUENTA'),
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
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'NOMBRE DE LA CUENTA',
                  hintText: 'Ej: Billetera Principal',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'TIPO'),
                items: _accountTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),

              // Balance
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'BALANCE INICIAL',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un balance';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Currency
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(labelText: 'MONEDA'),
                items: _currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency, style: const TextStyle(color: AppColors.textPrimary)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCurrency = value!),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(widget.account != null ? 'ACTUALIZAR' : 'CREAR CUENTA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
