import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  int _tab = 0; // 0 = Todas, 1 = No leídas, 2 = Críticas

  AppState get _state => AppState.instance;

  List<AppNotification> get _filtered {
    switch (_tab) {
      case 1:
        return _state.notificaciones.where((n) => !n.leida).toList();
      case 2:
        return _state.notificaciones.where((n) => n.critica).toList();
      default:
        return _state.notificaciones;
    }
  }

  @override
  Widget build(BuildContext context) {
    _state.ensureSeeded();

    return AppShell(
      currentRoute: AppRoutes.notificaciones,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Centro de Notificaciones',
            subtitle: 'Sincronizado en tiempo real con Galpones A-1 al B-4.',
            action: OutlinedButton.icon(
              onPressed: () {
                _state.markAllNotificationsRead();
                showAppSnackBar(
                  context,
                  'Todas las notificaciones marcadas como leídas',
                );
              },
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Marcar todo como leído'),
            ),
          ),
          const SizedBox(height: 24),
          _tabs(),
          const SizedBox(height: 16),
          _table(),
          const SizedBox(height: 24),
          _footerStatus(),
        ],
      ),
    );
  }

  Widget _tabs() {
    final tabs = [
      ('Todas', _state.notificaciones.length),
      ('No leídas', _state.unreadNotifications),
      ('Críticas', _state.criticalNotifications),
    ];
    return Wrap(
      spacing: 8,
      children: [
        for (var i = 0; i < tabs.length; i++)
          ChoiceChip(
            label: Text('${tabs[i].$1} ${tabs[i].$2}'),
            selected: _tab == i,
            onSelected: (_) => setState(() => _tab = i),
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              color: _tab == i ? AppColors.emerald900 : AppColors.textMuted,
            ),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
      ],
    );
  }

  Widget _table() {
    final items = _filtered;
    return SectionCard(
      padding: EdgeInsets.zero,
      child: items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              message: 'No hay notificaciones en esta categoría.',
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 64,
                dataRowMaxHeight: 96,
                columns: const [
                  DataColumn(label: Text('TIPO')),
                  DataColumn(label: Text('DETALLES DEL SUCESO')),
                  DataColumn(label: Text('FECHA / HORA')),
                  DataColumn(label: Text('ACCIÓN')),
                ],
                rows: [
                  for (final n in items)
                    DataRow(
                      cells: [
                        DataCell(_tipoChip(n)),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  n.titulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  n.detalle,
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            n.fecha,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                        DataCell(
                          TextButton(
                            onPressed: () => _ver(n),
                            child: const Text('Ver'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _tipoChip(AppNotification n) {
    final color = n.critica ? AppColors.danger : AppColors.info;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!n.leida)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        StatusChip(label: n.tipo, color: color),
      ],
    );
  }

  Widget _footerStatus() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 8,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done_outlined, size: 16, color: AppColors.success),
            SizedBox(width: 8),
            Text(
              'Servidor activo',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Text(
          'AVISENA COL v2.4.0 © 2026',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  void _ver(AppNotification n) {
    if (!n.leida) _state.markNotificationRead(n.id);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(n.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusChip(
              label: n.tipo,
              color: n.critica ? AppColors.danger : AppColors.info,
            ),
            const SizedBox(height: 12),
            Text(n.detalle),
            const SizedBox(height: 12),
            Text(
              n.fecha,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _state.removeNotificacion(n.id);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
