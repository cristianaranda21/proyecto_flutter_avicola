import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class ClasificacionPage extends StatelessWidget {
  const ClasificacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance..ensureSeeded();

    return AppShell(
      currentRoute: AppRoutes.clasificacion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Clasificación de Huevos',
            subtitle:
                'Clasifica la producción por tamaño y calcula el valor generado.',
            action: Builder(
              builder: (ctx) => ElevatedButton.icon(
                onPressed: () => _showAddDialog(ctx),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Agregar Nueva Clasificación'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _historial(state),
        ],
      ),
    );
  }

  Widget _historial(AppState state) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Historial de Clasificación',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          if (state.clasificaciones.isEmpty)
            const EmptyState(
              icon: Icons.egg_alt_outlined,
              message: 'No se encontraron registros de clasificación',
              hint: 'Agrega una nueva clasificación para comenzar el historial.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID / FECHA')),
                  DataColumn(label: Text('GALPÓN')),
                  DataColumn(label: Text('PRODUCCIÓN HOY')),
                  DataColumn(label: Text('SOBRANTES SIG.')),
                  DataColumn(label: Text('TOTAL DINERO')),
                  DataColumn(label: Text('RESPONSABLE')),
                  DataColumn(label: Text('ACCIONES')),
                ],
                rows: [
                  for (final c in state.clasificaciones)
                    DataRow(cells: [
                      DataCell(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c.id,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(c.fecha,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11)),
                        ],
                      )),
                      DataCell(Text(c.galpon)),
                      DataCell(Text(Formatters.number(c.produccionHoy))),
                      DataCell(Text(Formatters.number(c.sobrantesSiguiente))),
                      DataCell(Text(
                        Formatters.currency(c.totalDinero),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.success),
                      )),
                      DataCell(Text(c.responsable)),
                      DataCell(IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger, size: 20),
                        onPressed: () => state.removeClasificacion(c.id),
                      )),
                    ]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final state = AppState.instance;
    final galpon = TextEditingController(text: state.galpones.first);
    final sobrantes = TextEditingController(text: '0');
    final responsable = TextEditingController(text: state.session?.name ?? '');
    final counts = {
      for (final k in Clasificacion.tipoKeys)
        k: TextEditingController(text: '0'),
    };

    showFormDialog(
      context,
      title: 'Agregar Nueva Clasificación',
      maxWidth: 720,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          var total = 0;
          var dinero = 0.0;
          counts.forEach((k, controller) {
            final v = int.tryParse(controller.text.trim()) ?? 0;
            total += v;
            dinero += v * (Clasificacion.precios[k] ?? 0);
          });
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Galpón', required: true),
              TextField(controller: galpon),
              const SizedBox(height: 18),
              const Text('Conteo por tipo de huevo',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final k in Clasificacion.tipoKeys)
                    SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: kEggTypeColors[k],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('Tipo $k',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.currency(Clasificacion.precios[k] ?? 0),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: counts[k],
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setDialogState(() {}),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Sobrantes para siguiente'),
                        TextField(
                            controller: sobrantes,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Responsable'),
                        TextField(controller: responsable),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$total huevos clasificados',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(
                      Formatters.currency(dinero),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.emerald900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      onSave: () {
        final tipos = <String, int>{};
        for (final k in Clasificacion.tipoKeys) {
          tipos[k] = int.tryParse(counts[k]!.text.trim()) ?? 0;
        }
        final total = tipos.values.fold(0, (a, b) => a + b);
        if (total <= 0) {
          showAppSnackBar(context, 'Ingresa al menos un huevo clasificado',
              error: true);
          return;
        }
        state.addClasificacion(Clasificacion(
          id: state.nextClasificacionId(),
          fecha: Formatters.today(),
          galpon: galpon.text.trim(),
          tipos: tipos,
          sobrantesSiguiente: int.tryParse(sobrantes.text.trim()) ?? 0,
          responsable: responsable.text.trim(),
        ));
        showAppSnackBar(context, 'Clasificación registrada');
      },
    );
  }
}
