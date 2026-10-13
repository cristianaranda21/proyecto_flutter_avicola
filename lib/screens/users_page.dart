import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

const List<String> _roles = [
  'Instructor lider',
  'Instructor investigador',
  'Aprendiz de contrato',
];

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  String _roleFilter = 'Todos';
  final _documentController = TextEditingController();

  AppState get _state => AppState.instance;

  @override
  void dispose() {
    _documentController.dispose();
    super.dispose();
  }

  List<StaffUser> get _filtered {
    final doc = _documentController.text.trim();
    return _state.users.where((u) {
      final roleOk = _roleFilter == 'Todos' || u.role == _roleFilter;
      final docOk = doc.isEmpty || u.document.contains(doc);
      return roleOk && docOk;
    }).toList();
  }

  void _applyFilter() => setState(() {});

  @override
  Widget build(BuildContext context) {
    _state.ensureSeeded();
    final users = _filtered;

    return AppShell(
      currentRoute: AppRoutes.users,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Gestión de Usuarios',
            subtitle:
                'Administra el acceso al sistema, los roles y los datos del personal encargado de las operaciones avícolas',
            action: Wrap(
              spacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: _showRolesInfo,
                  icon: const Icon(Icons.security, size: 18),
                  label: const Text('Roles'),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.person_add_alt, size: 18),
                  label: const Text('Añadir Usuario'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _filtersCard(),
          const SizedBox(height: 24),
          _usersTable(users),
          const SizedBox(height: 24),
          _statsRow(),
        ],
      ),
    );
  }

  Widget _filtersCard() {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final rolField = DropdownButtonFormField<String>(
            initialValue: _roleFilter,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Rol',
              prefixIcon: Icon(Icons.badge_outlined, size: 18),
            ),
            items: [
              const DropdownMenuItem(value: 'Todos', child: Text('Todos')),
              for (final r in _roles)
                DropdownMenuItem(value: r, child: Text(r)),
            ],
            onChanged: (v) => setState(() => _roleFilter = v ?? 'Todos'),
          );
          final docField = TextFormField(
            controller: _documentController,
            decoration: const InputDecoration(
              labelText: 'Documento',
              prefixIcon: Icon(Icons.search, size: 18),
            ),
          );
          final filterBtn = ElevatedButton.icon(
            onPressed: _applyFilter,
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text('Filtrar'),
          );

          if (!wide) {
            return Column(
              children: [
                rolField,
                const SizedBox(height: 14),
                docField,
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: filterBtn),
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 2, child: rolField),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: docField),
              const SizedBox(width: 16),
              filterBtn,
            ],
          );
        },
      ),
    );
  }

  Widget _usersTable(List<StaffUser> users) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: users.isEmpty
          ? const EmptyState(
              icon: Icons.group_off_outlined,
              message: 'No hay usuarios que coincidan con la búsqueda.',
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('NOMBRE')),
                  DataColumn(label: Text('E-MAIL')),
                  DataColumn(label: Text('TELÉFONO')),
                  DataColumn(label: Text('Nº DOCUMENTO')),
                  DataColumn(label: Text('ROL')),
                  DataColumn(label: Text('RESIDENCIA')),
                  DataColumn(label: Text('INGRESO')),
                  DataColumn(label: Text('ACCIONES')),
                ],
                rows: [
                  for (final u in users)
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            u.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataCell(Text(u.email)),
                        DataCell(Text(u.phone)),
                        DataCell(Text(u.document)),
                        DataCell(
                          StatusChip(
                            label: u.role,
                            color: AppColors.emerald900,
                          ),
                        ),
                        DataCell(Text(u.residence)),
                        DataCell(Text(u.joinDate)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Eliminar',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.danger,
                                  size: 20,
                                ),
                                onPressed: () => _deleteUser(u),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _statsRow() {
    final total = _state.users.length;
    final activos = _state.usuariosActivos;
    final inactivos = _state.usuariosInhabilitados;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _statBlock(
            'Total Usuarios',
            '$total',
            Icons.groups_outlined,
            AppColors.info,
          ),
          _statBlock(
            'Usuarios Activos',
            '$activos',
            Icons.person_outline,
            AppColors.success,
          ),
          _statBlock(
            'Usuarios Inhabilitados',
            '$inactivos',
            Icons.person_off_outlined,
            AppColors.danger,
          ),
        ];
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                cards[i],
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: cards[i]),
              if (i < cards.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _statBlock(String label, String value, IconData icon, Color color) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textMuted)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRolesInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Roles del sistema'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RoleRow(
              'Instructor lider',
              'Acceso total: usuarios, finanzas y reportes.',
            ),
            SizedBox(height: 12),
            _RoleRow('Instructor investigador', 'Registros, lotes y reportes.'),
            SizedBox(height: 12),
            _RoleRow('Aprendiz de contrato', 'Registro de datos operativos.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final document = TextEditingController();
    final residence = TextEditingController();
    String role = _roles.first;

    showFormDialog(
      context,
      title: 'Añadir Usuario',
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Nombre completo', required: true),
            TextField(controller: name),
            const SizedBox(height: 14),
            const FieldLabel('Correo electrónico', required: true),
            TextField(controller: email),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Teléfono'),
                      TextField(controller: phone),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Nº Documento'),
                      TextField(controller: document),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const FieldLabel('Rol', required: true),
            DropdownButtonFormField<String>(
              initialValue: role,
              items: [
                for (final r in _roles)
                  DropdownMenuItem(value: r, child: Text(r)),
              ],
              onChanged: (v) => setDialogState(() => role = v ?? role),
            ),
            const SizedBox(height: 14),
            const FieldLabel('Residencia'),
            TextField(controller: residence),
          ],
        ),
      ),
      onSave: () {
        if (name.text.trim().isEmpty) {
          showAppSnackBar(context, 'El nombre es obligatorio', error: true);
          return;
        }
        _state.addUser(
          StaffUser(
            id: _state.nextUserId(),
            name: name.text.trim(),
            email: email.text.trim(),
            phone: phone.text.trim(),
            document: document.text.trim(),
            role: role,
            residence: residence.text.trim(),
            joinDate: Formatters.today(),
          ),
        );
        showAppSnackBar(context, 'Usuario añadido correctamente');
      },
    );
  }

  Future<void> _deleteUser(StaffUser user) async {
    final ok = await confirmDialog(
      context,
      title: 'Eliminar usuario',
      message: '¿Deseas eliminar a ${user.name}?',
    );
    if (!mounted) return;
    if (ok) {
      _state.removeUser(user.id);
      showAppSnackBar(context, 'Usuario eliminado');
    }
  }
}

class _RoleRow extends StatelessWidget {
  const _RoleRow(this.title, this.description);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(
          description,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
