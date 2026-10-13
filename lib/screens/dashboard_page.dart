import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance..ensureSeeded();
    final name = state.session?.name ?? 'Instructor Líder';

    return AppShell(
      currentRoute: AppRoutes.dashboard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeCard(name: name),
          const SizedBox(height: 24),
          _buildStats(state),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 980) {
                return Column(
                  children: [
                    _RecentReports(state: state),
                    const SizedBox(height: 24),
                    _RecentActivity(state: state),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _RecentReports(state: state)),
                  const SizedBox(width: 24),
                  Expanded(child: _RecentActivity(state: state)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AppState state) {
    final stats = [
      (
        'Usuarios Activos',
        '${state.usuariosActivos}',
        '+${state.usuariosInhabilitados == 0 ? 0 : 12}%',
        true,
      ),
      ('Reportes Semanales', '${state.reportesSemanales}', '-5%', false),
      ('Alertas de Alimento', '${state.alertasAlimento}', '+1%', true),
      ('Salud del Sistema', '${state.saludSistema}%', '0%', true),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 640
            ? 1
            : constraints.maxWidth < 1100
            ? 2
            : 4;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: columns == 1 ? 2.8 : 2.1,
          children: [
            for (final s in stats)
              StatCard(label: s.$1, value: s.$2, change: s.$3, positive: s.$4),
          ],
        );
      },
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Bienvenido, $name!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            'Bienvenido al sistema de gestión avícola AVISENA. Desde aquí podrás '
            'administrar la producción, monitorear la salud de las aves, registrar '
            'eventos importantes y consultar reportes de la granja.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                Formatters.today(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentReports extends StatelessWidget {
  const _RecentReports({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows(state);

    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 4,
              children: [
                const Text(
                  'Reportes Recientes',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.reportes,
                  ),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            const EmptyState(
              icon: Icons.description_outlined,
              message: 'Aún no hay reportes registrados.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('TIPO')),
                  DataColumn(label: Text('USUARIO')),
                  DataColumn(label: Text('FECHA')),
                  DataColumn(label: Text('ESTADO')),
                ],
                rows: rows,
              ),
            ),
        ],
      ),
    );
  }

  List<DataRow> _buildRows(AppState state) {
    final rows = <DataRow>[];

    for (var i = 0; i < state.producciones.length && i < 2; i++) {
      final p = state.producciones[i];
      rows.add(_row(p.id, 'Producción', p.trabajador, p.fecha, true));
    }
    for (var i = 0; i < state.clasificaciones.length && rows.length < 4; i++) {
      final c = state.clasificaciones[i];
      rows.add(_row(c.id, 'Clasificación', c.responsable, c.fecha, true));
    }
    for (var i = 0; i < state.mortalidades.length && rows.length < 5; i++) {
      final m = state.mortalidades[i];
      rows.add(_row(m.id, 'Mortalidad', m.galpon, m.fecha, false));
    }
    return rows;
  }

  DataRow _row(String id, String type, String user, String date, bool done) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w700))),
        DataCell(Text(type)),
        DataCell(
          Text(user, style: const TextStyle(color: AppColors.textMuted)),
        ),
        DataCell(
          Text(date, style: const TextStyle(color: AppColors.textMuted)),
        ),
        DataCell(
          StatusChip(
            label: done ? 'Completado' : 'Pendiente',
            color: done ? AppColors.success : AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final items = state.notificaciones.take(4).toList();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actividad Reciente',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            const Text('Sin actividad reciente.')
          else
            ...items.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            (n.critica ? AppColors.danger : AppColors.success)
                                .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconFor(n.tipo),
                        size: 16,
                        color: n.critica ? AppColors.danger : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            n.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            n.fecha,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.notificaciones,
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: const Text('Ver bitácora completa'),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String tipo) {
    switch (tipo) {
      case 'Mortalidad':
        return Icons.heart_broken_outlined;
      case 'Inventario':
        return Icons.inventory_2_outlined;
      case 'Ambiente':
        return Icons.thermostat;
      default:
        return Icons.trending_up;
    }
  }
}
