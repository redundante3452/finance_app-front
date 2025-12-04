import 'package:finance_app/core/auth/auth_provider.dart';
import 'package:finance_app/core/widgets/tech_text.dart';
import 'package:finance_app/core/widgets/eva_icon.dart';
import 'package:finance_app/features/user/screens/user_profile_screen.dart';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:finance_app/features/dashboard/widgets/charts_widget.dart';
import 'package:finance_app/features/dashboard/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer(
        builder: (context, ref, child) {
          final transactionsAsync = ref.watch(transactionsProvider);
          final accountsAsync = ref.watch(accountsProvider);
          final userAsync = ref.watch(currentUserProvider);

          return transactionsAsync.when(
            data: (transactions) {
              // Calculate totals from transactions
              double totalIncome = 0;
              double totalExpense = 0;

              for (var t in transactions) {
                if (t.type == 'INCOME') {
                  totalIncome += t.amount;
                } else {
                  totalExpense += t.amount;
                }
              }

              return accountsAsync.when(
                data: (accounts) {
                  // Calculate total balance from accounts
                  final totalBalance = accounts.fold<double>(
                    0, 
                    (sum, account) => sum + account.balance
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TechText(
                                      'HOLA, USUARIO',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    userAsync.when(
                                      data: (user) => Text(
                                        user?.name ?? 'Usuario',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      loading: () => const SizedBox(
                                        width: 100,
                                        height: 20,
                                        child: LinearProgressIndicator(),
                                      ),
                                      error: (_, __) => const Text('Usuario'),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UserProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.primary, width: 2),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppColors.surface,
                                    child: Icon(Icons.person, color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),

                        // Total Balance
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const TechText(
                                'BALANCE TOTAL',
                                style: TextStyle(
                                  color: AppColors.background,
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                cursorColor: AppColors.background,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${totalBalance.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: AppColors.background,
                                      fontSize: 40,
                                    ),
                              ).animate().scale(delay: 200.ms, duration: 500.ms),
                            ],
                          ),
                        ).animate()
                         .fadeIn(delay: 200.ms, duration: 600.ms)
                         .shimmer(delay: 1000.ms, duration: 1500.ms, color: Colors.white24)
                         .slideY(begin: 0.2, end: 0),
                         
                        const SizedBox(height: 24),

                        // Income / Expense Cards
                        Row(
                          children: [
                            Expanded(
                              child: SummaryCard(
                                title: 'Ingresos',
                                amount: totalIncome,
                                color: AppColors.success,
                                icon: Icons.arrow_downward,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SummaryCard(
                                title: 'Gastos',
                                amount: totalExpense,
                                color: AppColors.error,
                                icon: Icons.arrow_upward,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: 32),

                        // Charts Section
                        Text(
                          'Resumen Mensual',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
                        ).animate().fadeIn(delay: 600.ms),
                        
                        const SizedBox(height: 16),
                        
                        ChartsWidget(transactions: transactions)
                            .animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error cargando cuentas: $err')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error cargando transacciones: $err')),
          );
        },
      ),
    );
  }
}
