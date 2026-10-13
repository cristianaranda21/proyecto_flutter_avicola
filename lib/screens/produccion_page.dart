import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class ProduccionPage extends StatelessWidget {
  const ProduccionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance..ensureSeeded();

    return AppShell(
      currentRoute: AppRoutes.produccion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Producción Diaria',
            subtitle: 'Registra y controla la recolección de huevos del día.',
            action: Builder(
              builder: (ctx) => ElevatedButton.icon(
                onPressed: () => _showAddDialog(ctx),
                icon: const Icon(Icons.add_box_outlined, size: 18),
                label: const Text('Nuevo Registro'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _kpiGrid(state),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1000) {
                return Column(
                  children: [
                    _produccionTable(context, state),
                    const SizedBox(height: 24),
                    _requerimientoPanel(state),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _produccionTable(context, state)),
                  const SizedBox(width: 24),
                  Expanded(child: _requerimientoPanel(state)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _kpiGrid(AppState state) {
    final cards = [
      (
        'Total Huevos Hoy',
        Formatters.number(state.huevosHoy),
        Icons.egg_outlined,
        AppColors.primary,
      ),
      (
        'Edad de las Aves',
        '${state.edadAvesActual} Semanas',
        Icons.calendar_today_outlined,
        AppColors.info,
      ),
      (
        'Recolecciones Hoy',
        '${state.recoleccionesHoy}',
        Icons.layers_outlined,
        AppColors.warning,
      ),
      (
        'Galpón Monitoreado',
        state.galponMonitoreado,
        Icons.location_on_outlined,
        AppColors.emerald900,
      ),
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
          childAspectRatio: columns == 1
              ? 3.2
              : columns == 2
              ? 2.1
              : 1.6,
          children: [
            for (final c in cards)
              StatCard(label: c.$1, value: c.$2, icon: c.$3),
          ],
        );
      },
    );
  }

  Widget _produccionTable(BuildContext context, AppState state) {
    final rows = state.producciones;
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Producciones registradas',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            const EmptyState(
              icon: Icons.egg_outlined,
              message: 'No hay producciones pendientes de clasificar.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('FECHA')),
                  DataColumn(label: Text('GALPÓN')),
                  DataColumn(label: Text('LOTE')),
                  DataColumn(label: Text('LÍNEA')),
                  DataColumn(label: Text('EDAD')),
                  DataColumn(label: Text('BUENOS')),
                  DataColumn(label: Text('ROTOS')),
                  DataColumn(label: Text('DESCARTE')),
                  DataColumn(label: Text('TRABAJADOR')),
                  DataColumn(label: Text('ACCIONES')),
                ],
                rows: [
                  for (final p in rows)
                    DataRow(
                      cells: [
                        DataCell(Text(p.fecha)),
                        DataCell(
                          Text(
                            p.galpon,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataCell(Text(p.lote)),
                        DataCell(Text(p.linea)),
                        DataCell(Text('${p.edadSemanas} sem')),
                        DataCell(Text(Formatters.number(p.buenos))),
                        DataCell(Text(Formatters.number(p.rotos))),
                        DataCell(Text(Formatters.number(p.descarte))),
                        DataCell(Text(p.trabajador)),
                        DataCell(
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            onPressed: () => state.removeProduccion(p.id),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _requerimientoPanel(AppState state) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Consumo y Requerimiento',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 20),
          _metricRow(
            'Alimento Consumido (KG)',
            state.alimentoConsumidoHoy.toStringAsFixed(1),
          ),
          const SizedBox(height: 14),
          _metricRow(
            'Producción Estimada',
            Formatters.number(state.produccionEstimada),
          ),
          const SizedBox(height: 14),
          _metricRow('Puntaje CA Actual', state.puntajeCA.toStringAsFixed(2)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.sync, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Requerimiento: ${state.alimentoConsumidoHoy.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Nro. de Aves / g / Ave',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final d in days)
                Chip(
                  label: Text(d),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    final state = AppState.instance;
    final galpon = TextEditingController(text: state.galpones.first);
    final lote = TextEditingController(text: 'Lote 2026-A');
    final linea = TextEditingController(text: 'Hy-Line Brown');
    final edad = TextEditingController(text: '22');
    final buenos = TextEditingController();
    final rotos = TextEditingController(text: '0');
    final descarte = TextEditingController(text: '0');
    final trabajador = TextEditingController(text: state.session?.name ?? '');
    final alimento = TextEditingController(text: '0');

    showFormDialog(
      context,
      title: 'Nuevo Registro de Producción',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('Galpón', required: true),
          TextField(controller: galpon),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Lote'),
                    TextField(controller: lote),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Línea'),
                    TextField(controller: linea),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Edad (semanas)'),
                    TextField(
                      controller: edad,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Alimento (kg)'),
                    TextField(
                      controller: alimento,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Buenos', required: true),
                    TextField(
                      controller: buenos,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Rotos'),
                    TextField(
                      controller: rotos,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Descarte'),
                    TextField(
                      controller: descarte,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const FieldLabel('Trabajador'),
          TextField(controller: trabajador),
        ],
      ),
      onSave: () {
        final b = int.tryParse(buenos.text.trim()) ?? 0;
        if (b <= 0) {
          showAppSnackBar(
            context,
            'Ingresa una cantidad de huevos válida',
            error: true,
          );
          return;
        }
        state.addProduccion(
          ProduccionDiaria(
            id: state.nextProduccionId(),
            fecha: Formatters.today(),
            galpon: galpon.text.trim(),
            lote: lote.text.trim(),
            linea: linea.text.trim(),
            edadSemanas: int.tryParse(edad.text.trim()) ?? 0,
            buenos: b,
            rotos: int.tryParse(rotos.text.trim()) ?? 0,
            descarte: int.tryParse(descarte.text.trim()) ?? 0,
            trabajador: trabajador.text.trim(),
            alimentoKg: double.tryParse(alimento.text.trim()) ?? 0,
          ),
        );
        showAppSnackBar(context, 'Producción registrada');
      },
    );
  }
}
