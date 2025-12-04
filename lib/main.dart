import 'package:finance_app/core/auth/auth_provider.dart';
import 'package:finance_app/core/config/theme_config.dart';
import 'package:finance_app/features/auth/screens/login_screen.dart';
import 'package:finance_app/features/dashboard/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const ProviderScope(child: FinanceApp()));
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance App',
      debugShowCheckedModeBanner: false,
      theme: GamerTheme.theme,
      home: const AuthChecker(),
    );
  }
}

/// Checks authentication state and routes accordingly
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (isAuthenticated) {
        if (isAuthenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const LoginScreen(),
    );
  }
}
