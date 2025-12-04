import 'package:finance_app/core/auth/auth_provider.dart';
import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/widgets/hexagon_background.dart';
import 'package:finance_app/features/accounts/screens/accounts_screen.dart';
import 'package:finance_app/features/auth/screens/login_screen.dart';
import 'package:finance_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:finance_app/features/stats/screens/stats_screen.dart';
import 'package:finance_app/features/transactions/screens/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionListScreen(),
    const StatsScreen(),
    const AccountsScreen(),
  ];

  Future<void> _logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for floating bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que quieres salir?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCELAR'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('SALIR', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await _logout();
              }
            },
          ),
        ],
      ),
      body: HexagonBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent, // Transparent to show container color
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textDim,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  activeIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.swap_horiz_rounded),
                  activeIcon: Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                  label: 'Transacciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart_rounded),
                  activeIcon: Icon(Icons.pie_chart_rounded, color: AppColors.primary),
                  label: 'Estadísticas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wallet_rounded),
                  activeIcon: Icon(Icons.wallet_rounded, color: AppColors.primary),
                  label: 'Cuentas',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
