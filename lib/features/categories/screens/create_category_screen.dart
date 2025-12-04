import 'package:finance_app/core/auth/auth_provider.dart';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCategoryScreen extends ConsumerStatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  ConsumerState<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends ConsumerState<CreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _type = 'EXPENSE';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // userId is handled by backend via token

        final categoryData = {
          'name': _nameController.text,
          'transactionType': _type, // Backend expects 'transactionType' not 'type'
          // userId removed as backend forbids it
        };

        await ref.read(categoryServiceProvider).createCategory(categoryData);
        
        // Refresh list
        ref.invalidate(categoriesProvider);
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear categoría: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUEVA CATEGORÍA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej: Comida, Transporte',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Type Selection
              Text(
                'Tipo',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Gasto'),
                        value: 'EXPENSE',
                        groupValue: _type,
                        onChanged: (value) {
                          setState(() => _type = value!);
                        },
                        activeColor: AppColors.error,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Ingreso'),
                        value: 'INCOME',
                        groupValue: _type,
                        onChanged: (value) {
                          setState(() => _type = value!);
                        },
                        activeColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _type == 'INCOME' ? AppColors.success : AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'CREAR CATEGORÍA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
