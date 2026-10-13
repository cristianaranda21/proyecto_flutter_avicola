import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

const List<String> _afectaciones = ['Baja', 'Media', 'Alta'];

class MorbilidadPage extends StatelessWidget {
  const MorbilidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance..ensureSeeded();

    return AppShell(
      currentRoute: AppRoutes.morbilidad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Registro de Morbilidad y Causas',
            subtitle: 'Control y seguimiento de síntomas en aves.',
            action: Builder(
              builder: (ctx) => ElevatedButton.icon(
                onPressed: () => _showAddDialog(ctx),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Agregar Nueva Morbilidad'),
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
              'Historial de Morbilidad',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          if (state.morbilidades.isEmpty)
            const EmptyState(
              icon: Icons.medical_information_outlined,
              message: 'No se encontraron registros de morbilidad.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('FECHA')),
                  DataColumn(label: Text('LOTE')),
                  DataColumn(label: Text('SÍNTOMAS')),
                  DataColumn(label: Text('AFECTACIÓN')),
                  DataColumn(label: Text('ACCIÓN')),
                  DataColumn(label: Text('RESPONSABLE')),
                  DataColumn(label: Text('TRATAMIENTO')),
                  DataColumn(label: Text('ACCIONES')),
                ],
                rows: [
                  for (final m in state.morbilidades)
                    DataRow(cells: [
                      DataCell(Text(m.fecha)),
                      DataCell(Text(m.lote,
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(m.sintomas)),
                      DataCell(_afectacionChip(m.afectacion)),
                      DataCell(Text(m.accion)),
                      DataCell(Text(m.responsable)),
                      DataCell(Text(m.tratamiento)),
                      DataCell(IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger, size: 20),
                        onPressed: () => state.removeMorbilidad(m.id),
                      )),
                    ]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _afectacionChip(String afectacion) {
    final color = switch (afectacion) {
      'Alta' => AppColors.danger,
      'Media' => AppColors.warning,
      _ => AppColors.success,
    };
    return StatusChip(label: afectacion, color: color);
  }

  void _showAddDialog(BuildContext context) {
    final state = AppState.instance;
    final lote = TextEditingController(text: 'Lote 2026-A');
    final sintomas = TextEditingController();
    final accion = TextEditingController();
    final responsable = TextEditingController(text: state.session?.name ?? '');
    final tratamiento = TextEditingController(text: 'Ninguno');
    String afectacion = _afectaciones.first;

    showFormDialog(
      context,
      title: 'Agregar Nueva Morbilidad',
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Lote', required: true),
            TextField(controller: lote),
            const SizedBox(height: 14),
            const FieldLabel('Síntomas reportados', required: true),
            TextField(
              controller: sintomas,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Describe los síntomas observados...',
              ),
            ),
            const SizedBox(height: 14),
            const FieldLabel('Afectación'),
            DropdownButtonFormField<String>(
              initialValue: afectacion,
              items: [
                for (final a in _afectaciones)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) => setDialogState(() => afectacion = v ?? afectacion),
            ),
            const SizedBox(height: 14),
            const FieldLabel('Acción tomada'),
            TextField(controller: accion),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Responsable'),
                      TextField(controller: responsable),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Tratamiento'),
                      TextField(controller: tratamiento),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onSave: () {
        if (sintomas.text.trim().isEmpty) {
          showAppSnackBar(context, 'Describe los síntomas observados',
              error: true);
          return;
        }
        state.addMorbilidad(Morbilidad(
          id: state.nextMorbilidadId(),
          fecha: Formatters.today(),
          lote: lote.text.trim(),
          sintomas: sintomas.text.trim(),
          afectacion: afectacion,
          accion: accion.text.trim(),
          responsable: responsable.text.trim(),
          tratamiento: tratamiento.text.trim(),
        ));
        showAppSnackBar(context, 'Registro de morbilidad guardado');
      },
    );
  }
}
