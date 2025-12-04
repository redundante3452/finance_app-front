import 'package:finance_app/core/config/app_colors.dart';
import 'package:finance_app/core/widgets/tech_text.dart';
import 'package:finance_app/core/auth/auth_provider.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:finance_app/features/auth/screens/login_screen.dart';
import 'package:finance_app/features/user/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final secureStorage = ref.read(secureStorageProvider);
  return UserService(apiClient, secureStorage);
});

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isEditingProfile = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkAuthValidity();
  }

  Future<void> _checkAuthValidity() async {
    // Check if user_id exists in storage
    final authService = ref.read(authServiceProvider);
    final userId = await authService.getUserId();
    
    if (userId == null || userId.isEmpty) {
      // User data is corrupted, force logout
      if (mounted) {
        await authService.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        
        // Show message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesión expirada. Por favor inicia sesión nuevamente.'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    final userAsync = ref.read(currentUserProvider);
    userAsync.whenData((user) {
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(userServiceProvider).updateProfile(
        name: _nameController.text,
        email: _emailController.text,
      );

      // Update stored user data
      final authService = ref.read(authServiceProvider);
      await authService.logout(); // Clear old data
      // Re-save with new data would need to be implemented in auth service
      
      ref.invalidate(currentUserProvider);
      
      setState(() => _isEditingProfile = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      final errorMessage = e.toString();
      
      // Check for specific errors
      if (errorMessage.contains('correo electrónico ya está en uso') ||
          errorMessage.contains('email already') ||
          errorMessage.contains('Conflict') ||
          errorMessage.contains('409')) {
        _showError('Este correo electrónico ya está registrado por otro usuario');
      } else if (errorMessage.contains('no autenticado') || 
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('401')) {
        // If authentication error, force logout
        await ref.read(authServiceProvider).logout();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión expirada. Por favor inicia sesión nuevamente.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        _showError('Error al actualizar perfil: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Las contraseñas no coinciden');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(userServiceProvider).updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      setState(() => _isChangingPassword = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      final errorMessage = e.toString();
      
      // If authentication error, force logout
      if (errorMessage.contains('no autenticado') || 
          errorMessage.contains('Unauthorized') ||
          errorMessage.contains('401')) {
        await ref.read(authServiceProvider).logout();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión expirada. Por favor inicia sesión nuevamente.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        _showError('Error al cambiar contraseña: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _logout() async {
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
      final authService = ref.read(authServiceProvider);
      await authService.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return FutureBuilder<String?>(
      future: ref.read(authServiceProvider).getUserId(),
      builder: (context, userIdSnapshot) {
        final hasValidSession = userIdSnapshot.connectionState == ConnectionState.done &&
            userIdSnapshot.data != null &&
            userIdSnapshot.data!.isNotEmpty;

        return PopScope(
          canPop: hasValidSession, // Only allow back navigation if session is valid
          onPopInvoked: (didPop) {
            if (!hasValidSession && !didPop) {
              // Show message that they can't go back
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor inicia sesión para continuar'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const TechText(
                'PERFIL DE USUARIO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              // Only show back button if session is valid
              leading: hasValidSession
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              automaticallyImplyLeading: false, // Disable default back button
            ),
      body: FutureBuilder<String?>(
        future: ref.read(authServiceProvider).getUserId(),
        builder: (context, snapshot) {
          // If user_id is missing, show warning and logout button
          if (snapshot.connectionState == ConnectionState.done && 
              (snapshot.data == null || snapshot.data!.isEmpty)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 80,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sesión Inválida',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tu sesión está corrupta o expirada.\nPor favor inicia sesión nuevamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(authServiceProvider).logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('INICIAR SESIÓN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Normal profile view
          return userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No hay usuario autenticado'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person, size: 60, color: AppColors.primary),
                    ),
                  ).animate().scale(duration: 600.ms),
                ),
                const SizedBox(height: 32),

                // Profile Information Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'INFORMACIÓN PERSONAL',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (!_isEditingProfile)
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary),
                              onPressed: () => setState(() => _isEditingProfile = true),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Name Field
                      TextField(
                        controller: _nameController,
                        enabled: _isEditingProfile,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                          filled: true,
                          fillColor: _isEditingProfile ? AppColors.background : AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Email Field
                      TextField(
                        controller: _emailController,
                        enabled: _isEditingProfile,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                          filled: true,
                          fillColor: _isEditingProfile ? AppColors.background : AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                          ),
                        ),
                      ),
                      
                      if (_isEditingProfile) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _nameController.text = user.name;
                                  _emailController.text = user.email;
                                  setState(() => _isEditingProfile = false);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(color: AppColors.textSecondary),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('CANCELAR'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('GUARDAR'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 24),

                // Change Password Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'CAMBIAR CONTRASEÑA',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (!_isChangingPassword)
                            IconButton(
                              icon: const Icon(Icons.lock_outline, color: AppColors.secondary),
                              onPressed: () => setState(() => _isChangingPassword = true),
                            ),
                        ],
                      ),
                      
                      if (_isChangingPassword) ...[
                        const SizedBox(height: 20),
                        
                        // Current Password
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Contraseña Actual',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // New Password
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Nueva Contraseña',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            prefixIcon: const Icon(Icons.lock, color: AppColors.secondary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Confirm Password
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Confirmar Contraseña',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            prefixIcon: const Icon(Icons.lock_reset, color: AppColors.secondary),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _currentPasswordController.clear();
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();
                                  setState(() => _isChangingPassword = false);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(color: AppColors.textSecondary),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('CANCELAR'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _updatePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('CAMBIAR'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('CERRAR SESIÓN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).scale(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      );
        },
      ),
          ),
        );
      },
    );
  }
}
