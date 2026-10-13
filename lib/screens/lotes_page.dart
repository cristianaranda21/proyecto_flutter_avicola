import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class LotesPage extends StatefulWidget {
  const LotesPage({super.key});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  static const _pageSize = 10;

  final _searchController = TextEditingController();
  int _page = 0;

  AppState get _state => AppState.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Lote> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _state.lotes;
    return _state.lotes
        .where(
          (l) =>
              l.galpon.toLowerCase().contains(q) ||
              l.linea.toLowerCase().contains(q) ||
              l.responsable.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    _state.ensureSeeded();
    final lotes = _filtered;
    final pageCount = lotes.isEmpty ? 1 : (lotes.length - 1) ~/ _pageSize + 1;
    final firstRow = _page * _pageSize;
    final visibleLotes = lotes.skip(firstRow).take(_pageSize).toList();
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return AppShell(
      currentRoute: AppRoutes.lotes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Registro de Galpones',
            subtitle: 'Control y seguimiento de tus lotes de aves.',
            action: ElevatedButton.icon(
              onPressed: _showAddLoteDialog,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Agregar nuevo galpon'),
            ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: isWide
                      ? Row(
                          children: [
                            const Text(
                              'Historial de Galpones',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(width: 240, child: _searchField()),
                            const SizedBox(width: 12),
                            _exportButton(),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Historial de Galpones',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _searchField(),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: _exportButton(),
                            ),
                          ],
                        ),
                ),
                const Divider(height: 1),
                if (lotes.isEmpty)
                  const EmptyState(
                    icon: Icons.inventory_2_outlined,
                    message: 'No se encontraron registros de Galpones.',
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('FECHA INGRESO')),
                        DataColumn(label: Text('HORA')),
                        DataColumn(label: Text('GALPÓN')),
                        DataColumn(label: Text('PESO PROM.')),
                        DataColumn(label: Text('SEMANA')),
                        DataColumn(label: Text('Nº AVES')),
                        DataColumn(label: Text('LÍNEA')),
                        DataColumn(label: Text('RESPONSABLE')),
                        DataColumn(label: Text('CERT.')),
                        DataColumn(label: Text('INFORME')),
                        DataColumn(label: Text('ACCIONES')),
                      ],
                      rows: visibleLotes.map(_buildRow).toList(),
                    ),
                  ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: _page > 0
                            ? () => setState(() => _page--)
                            : null,
                        child: const Text('Anterior'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_page + 1} / $pageCount',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      TextButton(
                        onPressed: _page + 1 < pageCount
                            ? () => setState(() => _page++)
                            : null,
                        child: const Text('Siguiente'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() => _page = 0),
      decoration: const InputDecoration(
        hintText: 'Buscar galpón...',
        prefixIcon: Icon(Icons.search, size: 18),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _exportButton() {
    return OutlinedButton.icon(
      onPressed: _exportCsv,
      icon: const Icon(Icons.file_download_outlined, size: 18),
      label: const Text('Exportar'),
    );
  }

  Future<void> _exportCsv() async {
    String csvValue(String value) => '"${value.replaceAll('"', '""')}"';

    final rows = [
      [
        'Fecha de ingreso',
        'Hora',
        'Galpón',
        'Peso promedio',
        'Semanas',
        'Aves',
        'Línea',
        'Responsable',
        'Certificados',
        'Informe',
      ],
      for (final lote in _filtered)
        [
          lote.fechaIngreso,
          lote.horaIngreso,
          lote.galpon,
          lote.pesoPromedio,
          '${lote.semanasVida}',
          '${lote.numAves}',
          lote.linea,
          lote.responsable,
          lote.certificados ? 'Sí' : 'No',
          lote.informe ? 'Sí' : 'No',
        ],
    ];
    final csv = rows.map((row) => row.map(csvValue).join(',')).join('\n');
    await Clipboard.setData(ClipboardData(text: csv));
    if (mounted) {
      showAppSnackBar(context, '${_filtered.length} registros CSV copiados');
    }
  }

  DataRow _buildRow(Lote l) {
    return DataRow(
      cells: [
        DataCell(Text(l.fechaIngreso)),
        DataCell(Text(l.horaIngreso)),
        DataCell(
          Text(l.galpon, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        DataCell(Text(l.pesoPromedio)),
        DataCell(Text('${l.semanasVida}')),
        DataCell(Text(Formatters.number(l.numAves))),
        DataCell(Text(l.linea)),
        DataCell(Text(l.responsable)),
        DataCell(
          Icon(
            l.certificados ? Icons.check_circle : Icons.cancel,
            color: l.certificados ? AppColors.success : AppColors.danger,
            size: 20,
          ),
        ),
        DataCell(
          l.informe
              ? const Icon(Icons.description, color: AppColors.info, size: 20)
              : const Text('-', style: TextStyle(color: AppColors.textMuted)),
        ),
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
                onPressed: () => _deleteLote(l),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddLoteDialog() {
    final galpon = TextEditingController();
    final peso = TextEditingController();
    final semanas = TextEditingController();
    final numAves = TextEditingController();
    final linea = TextEditingController();
    final responsable = TextEditingController();
    bool certificados = true;
    bool informe = false;

    showFormDialog(
      context,
      title: 'Agregar nuevo galpón',
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Galpón', required: true),
            TextField(
              controller: galpon,
              decoration: const InputDecoration(hintText: 'Galpón A-2'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Peso promedio'),
                      TextField(
                        controller: peso,
                        decoration: const InputDecoration(hintText: '1.2 kg'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Semana de vida'),
                      TextField(
                        controller: semanas,
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
                      const FieldLabel('Número de aves'),
                      TextField(
                        controller: numAves,
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
                      const FieldLabel('Línea de aves'),
                      TextField(
                        controller: linea,
                        decoration: const InputDecoration(
                          hintText: 'Hy-Line Brown',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const FieldLabel('Responsable'),
            TextField(controller: responsable),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: certificados,
                    onChanged: (v) =>
                        setDialogState(() => certificados = v ?? false),
                    title: const Text('Certificados'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    value: informe,
                    onChanged: (v) =>
                        setDialogState(() => informe = v ?? false),
                    title: const Text('Informe'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onSave: () {
        if (galpon.text.trim().isEmpty) {
          showAppSnackBar(context, 'El galpón es obligatorio', error: true);
          return;
        }
        _state.addLote(
          Lote(
            id: _state.nextLoteId(),
            fechaIngreso: Formatters.today(),
            horaIngreso: Formatters.nowTime(),
            galpon: galpon.text.trim(),
            pesoPromedio: peso.text.trim().isEmpty ? '--' : peso.text.trim(),
            semanasVida: int.tryParse(semanas.text.trim()) ?? 0,
            numAves: int.tryParse(numAves.text.trim()) ?? 0,
            linea: linea.text.trim().isEmpty ? '--' : linea.text.trim(),
            responsable: responsable.text.trim().isEmpty
                ? '--'
                : responsable.text.trim(),
            certificados: certificados,
            informe: informe,
          ),
        );
        showAppSnackBar(context, 'Galpón registrado');
      },
    );
  }

  Future<void> _deleteLote(Lote lote) async {
    final ok = await confirmDialog(
      context,
      title: 'Eliminar galpón',
      message: '¿Deseas eliminar ${lote.galpon}?',
    );
    if (!mounted) return;
    if (ok) {
      _state.removeLote(lote.id);
      final pageCount = _filtered.isEmpty
          ? 1
          : (_filtered.length - 1) ~/ _pageSize + 1;
      if (_page >= pageCount) _page = pageCount - 1;
      showAppSnackBar(context, 'Galpón eliminado');
    }
  }
}
