import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

const List<String> _tipos = ['Antibiótico', 'Vitamínico', 'Desparasitante', 'Vacuna'];
const List<String> _vias = ['Oral (agua)', 'Oral (alimento)', 'Inyectable', 'Tópica'];
const List<String> _estados = ['Activo', 'Finalizado', 'Suspendido'];

class TratamientoPage extends StatelessWidget {
  const TratamientoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance..ensureSeeded();

    return AppShell(
      currentRoute: AppRoutes.tratamiento,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Gestión de Tratamientos',
            subtitle: 'Registro y seguimiento de tratamientos aplicados.',
            action: Builder(
              builder: (ctx) => ElevatedButton.icon(
                onPressed: () => _showAddDialog(ctx),
                icon: const Icon(Icons.add_box_outlined, size: 18),
                label: const Text('Agregar Nuevo Tratamiento'),
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
              'Historial de Tratamientos',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          if (state.tratamientos.isEmpty)
            const EmptyState(
              icon: Icons.medication_outlined,
              message: 'No hay tratamientos registrados aún',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('MEDICAMENTO')),
                  DataColumn(label: Text('TIPO')),
                  DataColumn(label: Text('UBICACIÓN')),
                  DataColumn(label: Text('VÍA')),
                  DataColumn(label: Text('INICIO')),
                  DataColumn(label: Text('DURACIÓN')),
                  DataColumn(label: Text('DIAGNÓSTICO')),
                  DataColumn(label: Text('RESPONSABLE')),
                  DataColumn(label: Text('ESTADO')),
                  DataColumn(label: Text('ACCIONES')),
                ],
                rows: [
                  for (final t in state.tratamientos)
                    DataRow(cells: [
                      DataCell(Text(t.medicamento,
                          style: const TextStyle(fontWeight: FontWeight.w700))),
                      DataCell(Text(t.tipo)),
                      DataCell(Text(t.ubicacion)),
                      DataCell(Text(t.via)),
                      DataCell(Text(t.inicio)),
                      DataCell(Text(t.duracion)),
                      DataCell(Text(t.diagnostico)),
                      DataCell(Text(t.responsable)),
                      DataCell(_estadoChip(t.estado)),
                      DataCell(IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger, size: 20),
                        onPressed: () => state.removeTratamiento(t.id),
                      )),
                    ]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _estadoChip(String estado) {
    final color = switch (estado) {
      'Activo' => AppColors.success,
      'Suspendido' => AppColors.warning,
      _ => AppColors.textMuted,
    };
    return StatusChip(label: estado, color: color);
  }

  void _showAddDialog(BuildContext context) {
    final state = AppState.instance;
    final medicamento = TextEditingController();
    final ubicacion = TextEditingController(text: state.galpones.first);
    final duracion = TextEditingController(text: '5 días');
    final diagnostico = TextEditingController();
    final responsable = TextEditingController(text: state.session?.name ?? '');
    String tipo = _tipos.first;
    String via = _vias.first;
    String estado = _estados.first;

    showFormDialog(
      context,
      title: 'Agregar Nuevo Tratamiento',
      maxWidth: 720,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Medicamento', required: true),
            TextField(controller: medicamento),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Tipo'),
                      DropdownButtonFormField<String>(
                        initialValue: tipo,
                        items: [
                          for (final t in _tipos)
                            DropdownMenuItem(value: t, child: Text(t)),
                        ],
                        onChanged: (v) => setDialogState(() => tipo = v ?? tipo),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Vía de administración'),
                      DropdownButtonFormField<String>(
                        initialValue: via,
                        items: [
                          for (final v in _vias)
                            DropdownMenuItem(value: v, child: Text(v)),
                        ],
                        onChanged: (x) => setDialogState(() => via = x ?? via),
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
                      const FieldLabel('Ubicación'),
                      TextField(controller: ubicacion),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Duración'),
                      TextField(controller: duracion),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const FieldLabel('Morbilidad / Diagnóstico'),
            TextField(controller: diagnostico),
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
                      const FieldLabel('Estado'),
                      DropdownButtonFormField<String>(
                        initialValue: estado,
                        items: [
                          for (final e in _estados)
                            DropdownMenuItem(value: e, child: Text(e)),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => estado = v ?? estado),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onSave: () {
        if (medicamento.text.trim().isEmpty) {
          showAppSnackBar(context, 'El medicamento es obligatorio',
              error: true);
          return;
        }
        state.addTratamiento(Tratamiento(
          id: state.nextTratamientoId(),
          medicamento: medicamento.text.trim(),
          tipo: tipo,
          ubicacion: ubicacion.text.trim(),
          via: via,
          inicio: Formatters.today(),
          duracion: duracion.text.trim(),
          diagnostico: diagnostico.text.trim(),
          responsable: responsable.text.trim(),
          estado: estado,
        ));
        showAppSnackBar(context, 'Tratamiento registrado');
      },
    );
  }
}
