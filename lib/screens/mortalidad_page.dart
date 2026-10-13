import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

const List<String> _causas = [
  'Enfermedad',
  'Estrés térmico',
  'Accidente',
  'Depredador',
  'Causa desconocida',
];

const List<String> _disposiciones = [
  'Incineración',
  'Compostaje',
  'Fosa sanitaria',
  'Entrega a gestor',
];

class MortalidadPage extends StatelessWidget {
  const MortalidadPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance..ensureSeeded();

    return AppShell(
      currentRoute: AppRoutes.mortalidad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Mortalidad de las aves',
            subtitle:
                'Registra y gestiona organizadamente los datos relacionados con la mortalidad de las aves, dentro de tu unidad avícola.',
            action: Builder(
              builder: (ctx) => ElevatedButton.icon(
                onPressed: () => _showAddDialog(ctx),
                icon: const Icon(Icons.add_box_outlined, size: 18),
                label: const Text('Nuevo Registro'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _historial(state),
          const SizedBox(height: 24),
          _stats(state),
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
              'Historial de Mortalidad',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          if (state.mortalidades.isEmpty)
            const EmptyState(
              icon: Icons.heart_broken_outlined,
              message: 'No hay registros de mortalidad.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('FECHA')),
                  DataColumn(label: Text('GALPÓN')),
                  DataColumn(label: Text('CANTIDAD')),
                  DataColumn(label: Text('EDAD')),
                  DataColumn(label: Text('CAUSA')),
                  DataColumn(label: Text('NECROPSIA')),
                  DataColumn(label: Text('DISPOSICIÓN')),
                  DataColumn(label: Text('ACCIONES')),
                ],
                rows: [
                  for (final m in state.mortalidades)
                    DataRow(
                      cells: [
                        DataCell(Text(m.fecha)),
                        DataCell(
                          Text(
                            m.galpon,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataCell(Text('${m.cantidad}')),
                        DataCell(Text('${m.edadSemanas} sem')),
                        DataCell(Text(m.causa)),
                        DataCell(Text(m.necropsia)),
                        DataCell(Text(m.disposicion)),
                        DataCell(
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            onPressed: () => state.removeMortalidad(m.id),
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

  Widget _stats(AppState state) {
    final cards = [
      (
        'Mortalidad Total Mensual',
        '${state.mortalidadTotalMes}',
        Icons.trending_up,
        AppColors.info,
      ),
      (
        'Causa Principal',
        state.causaPrincipalMortalidad,
        Icons.analytics_outlined,
        AppColors.warning,
      ),
      (
        'Actas Generadas',
        '${state.mortalidades.length}',
        Icons.task_alt,
        AppColors.success,
      ),
      (
        'Tasa de Mortalidad',
        '${state.tasaMortalidad.toStringAsFixed(1)}%',
        Icons.warning_amber_outlined,
        AppColors.danger,
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
          childAspectRatio: columns == 1 ? 2.8 : 1.8,
          children: [
            for (final c in cards)
              StatCard(label: c.$1, value: c.$2, icon: c.$3),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    final state = AppState.instance;
    final galpon = TextEditingController(text: state.galpones.first);
    final cantidad = TextEditingController();
    final edad = TextEditingController(text: '22');
    final necropsia = TextEditingController(text: 'No realizada');
    String causa = _causas.first;
    String disposicion = _disposiciones.first;

    showFormDialog(
      context,
      title: 'Nuevo Registro de Mortalidad',
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
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
                      const FieldLabel('Cantidad de aves', required: true),
                      TextField(
                        controller: cantidad,
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
                      const FieldLabel('Edad en semanas'),
                      TextField(
                        controller: edad,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const FieldLabel('Causa'),
            DropdownButtonFormField<String>(
              initialValue: causa,
              items: [
                for (final c in _causas)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setDialogState(() => causa = v ?? causa),
            ),
            const SizedBox(height: 14),
            const FieldLabel('Necropsia'),
            TextField(controller: necropsia),
            const SizedBox(height: 14),
            const FieldLabel('Disposición final'),
            DropdownButtonFormField<String>(
              initialValue: disposicion,
              items: [
                for (final d in _disposiciones)
                  DropdownMenuItem(value: d, child: Text(d)),
              ],
              onChanged: (v) =>
                  setDialogState(() => disposicion = v ?? disposicion),
            ),
          ],
        ),
      ),
      onSave: () {
        final c = int.tryParse(cantidad.text.trim()) ?? 0;
        if (c <= 0) {
          showAppSnackBar(context, 'Ingresa una cantidad válida', error: true);
          return;
        }
        state.addMortalidad(
          Mortalidad(
            id: state.nextMortalidadId(),
            fecha: Formatters.today(),
            galpon: galpon.text.trim(),
            cantidad: c,
            edadSemanas: int.tryParse(edad.text.trim()) ?? 0,
            causa: causa,
            necropsia: necropsia.text.trim(),
            disposicion: disposicion,
          ),
        );
        showAppSnackBar(context, 'Registro de mortalidad guardado');
      },
    );
  }
}
