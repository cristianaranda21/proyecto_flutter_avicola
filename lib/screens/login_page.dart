import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _remember = false;
  AppRole _role = AppRole.admin;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    AppState.instance.login(_role);
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  void _showPasswordRecovery() {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: Icon(Icons.mail_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (!email.contains('@')) {
                showAppSnackBar(
                  context,
                  'Escribe un correo válido',
                  error: true,
                );
                return;
              }
              Navigator.pop(dialogContext);
              showAppSnackBar(
                context,
                'La recuperación automática no está configurada. Contacta al administrador.',
              );
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    ).whenComplete(emailController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/logo-sena-verde-complementario-svg-2022.svg',
                        width: 44,
                        height: 44,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AVISENA COL',
                        style: TextStyle(
                          fontSize: MediaQuery.sizeOf(context).width < 420
                              ? 24
                              : 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Iniciar sesión',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ingresa tus credenciales para continuar',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 28),
                        const FieldLabel('Correo electrónico o Usuario'),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            hintText: 'admin@granja.com',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const FieldLabel('Contraseña'),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const FieldLabel('Rol del usuario'),
                        DropdownButtonFormField<AppRole>(
                          initialValue: _role,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          items: [
                            for (final r in AppRole.values)
                              DropdownMenuItem(
                                value: r,
                                child: Text(r.displayName),
                              ),
                          ],
                          onChanged: (v) => setState(() => _role = v ?? _role),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _remember,
                                  onChanged: (v) =>
                                      setState(() => _remember = v ?? false),
                                ),
                                const Text('Recordarme'),
                              ],
                            ),
                            TextButton(
                              onPressed: _showPasswordRecovery,
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: const Text('INICIAR SESIÓN'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'continuar con',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _socialButton(
                                'assets/images/google.png',
                                'Google',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _socialButton(
                                'assets/images/facebook.png',
                                'Facebook',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '© 2026 AVISENA COL. Todos los derechos reservados.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String asset, String label) {
    return OutlinedButton(
      onPressed: () => showAppSnackBar(
        context,
        'El acceso con $label requiere configurar el proveedor OAuth.',
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Image.asset(
              asset,
              errorBuilder: (_, _, _) => const Icon(Icons.public, size: 18),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
