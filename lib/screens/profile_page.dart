import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _phone = TextEditingController(text: '3001234567');
  final _birthDate = TextEditingController(text: '15/01/1990');
  final _city = TextEditingController(text: 'Pasto');
  final _barrio = TextEditingController(text: 'Barrio Centro');
  String _sexo = 'Masculino';

  AppState get _state => AppState.instance;

  @override
  void initState() {
    super.initState();
    final session = _state.session ?? AppUserSession.forRole(AppRole.admin);
    _name = TextEditingController(text: session.name);
    _email = TextEditingController(text: session.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _birthDate.dispose();
    _city.dispose();
    _barrio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _state.ensureSeeded();
    final session = _state.session ?? AppUserSession.forRole(AppRole.admin);

    return AppShell(
      currentRoute: AppRoutes.profile,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatarCard(session, wide),
              const SizedBox(height: 24),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos personales',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _responsiveRow(wide, [
                      _field('Nombre Completo', _name),
                      _field('Correo Electrónico', _email),
                    ]),
                    const SizedBox(height: 16),
                    _responsiveRow(wide, [
                      _field('Número de Teléfono', _phone),
                      _field('Fecha de Nacimiento', _birthDate),
                    ]),
                    const SizedBox(height: 16),
                    _responsiveRow(wide, [_roleField(session), _sexoField()]),
                    const SizedBox(height: 16),
                    _responsiveRow(wide, [
                      _field('Ciudad', _city),
                      _field('Barrio / Vereda', _barrio),
                    ]),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Guardar Cambios'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _responsiveRow(bool wide, List<Widget> children) {
    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _avatarCard(AppUserSession session, bool wide) {
    return SectionCard(
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Text(
                  session.name.isEmpty ? '?' : session.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.emerald900,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  session.role.label,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      showAppSnackBar(context, 'Selección de imagen (demo)'),
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Cambiar Foto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        TextField(controller: controller),
      ],
    );
  }

  Widget _roleField(AppUserSession session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Rol'),
        TextField(
          controller: TextEditingController(text: session.role.label),
          enabled: false,
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.lock_outline, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _sexoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Sexo (Opcional)'),
        DropdownButtonFormField<String>(
          initialValue: _sexo,
          items: const [
            DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
            DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
            DropdownMenuItem(value: 'Otro', child: Text('Otro')),
          ],
          onChanged: (v) => setState(() => _sexo = v ?? _sexo),
        ),
      ],
    );
  }

  void _save() {
    _state.updateProfile(name: _name.text.trim(), email: _email.text.trim());
    showAppSnackBar(context, 'Perfil actualizado correctamente');
  }
}
