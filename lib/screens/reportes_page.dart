import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  static const String _tipoProduccion = 'Producción de huevos';
  static const String _tipoClasificacion = 'Clasificación de huevos';
  static const String _tipoMortalidad = 'Mortalidad de aves';
  static const String _tipoMorbilidad = 'Morbilidad de aves';

  String _tipo = _tipoProduccion;
  String _galpon = 'Todos los galpones';
  DateTime? _inicio;
  DateTime? _fin;
  List<ReportRow> _rows = const [];

  AppState get _state => AppState.instance;

  List<String> get _galponOptions => ['Todos los galpones', ..._state.galpones];

  Future<void> _pickDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _inicio = picked;
        } else {
          _fin = picked;
        }
      });
    }
  }

  DateTime? _parse(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  bool _inRange(String fecha) {
    if (_inicio == null && _fin == null) return true;
    final d = _parse(fecha);
    if (d == null) return true;
    if (_inicio != null &&
        d.isBefore(DateTime(_inicio!.year, _inicio!.month, _inicio!.day))) {
      return false;
    }
    if (_fin != null &&
        d.isAfter(DateTime(_fin!.year, _fin!.month, _fin!.day))) {
      return false;
    }
    return true;
  }

  void _generar() {
    final rows = <ReportRow>[];
    bool matchGalpon(String g) =>
        _galpon == 'Todos los galpones' || g == _galpon;

    switch (_tipo) {
      case _tipoProduccion:
        for (final p in _state.producciones) {
          if (matchGalpon(p.galpon) && _inRange(p.fecha)) {
            rows.add(
              ReportRow(fecha: p.fecha, galpon: p.galpon, cantidad: p.buenos),
            );
          }
        }
        break;
      case _tipoClasificacion:
        for (final c in _state.clasificaciones) {
          if (matchGalpon(c.galpon) && _inRange(c.fecha)) {
            rows.add(
              ReportRow(
                fecha: c.fecha,
                galpon: c.galpon,
                cantidad: c.produccionHoy,
              ),
            );
          }
        }
        break;
      case _tipoMortalidad:
        for (final m in _state.mortalidades) {
          if (matchGalpon(m.galpon) && _inRange(m.fecha)) {
            rows.add(
              ReportRow(fecha: m.fecha, galpon: m.galpon, cantidad: m.cantidad),
            );
          }
        }
        break;
      case _tipoMorbilidad:
        for (final m in _state.morbilidades) {
          if ((_galpon == 'Todos los galpones' || m.lote == _galpon) &&
              _inRange(m.fecha)) {
            rows.add(ReportRow(fecha: m.fecha, galpon: m.lote, cantidad: 1));
          }
        }
        break;
    }
    setState(() {
      _rows = rows;
    });
  }

  Future<void> _exportPdf() async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, text: 'Reporte de $_tipo'),
          pw.Paragraph(text: 'Galpón: $_galpon'),
          pw.Paragraph(
            text:
                'Período: ${_inicio == null ? 'Sin inicio' : Formatters.date(_inicio!)} - ${_fin == null ? 'Sin fin' : Formatters.date(_fin!)}',
          ),
          pw.TableHelper.fromTextArray(
            headers: const ['Fecha', 'Galpón', 'Cantidad'],
            data: [
              for (final row in _rows)
                [row.fecha, row.galpon, Formatters.number(row.cantidad)],
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('Total: ${Formatters.number(_total)}'),
        ],
      ),
    );

    final bytes = await document.save();
    final printed = await Printing.layoutPdf(
      name: 'avisena-reporte.pdf',
      onLayout: (_) async => bytes,
    );
    if (mounted && printed) {
      showAppSnackBar(context, 'PDF enviado al sistema de impresión.');
    }
  }

  int get _total => _rows.fold(0, (a, r) => a + r.cantidad);
  double get _promedio => _rows.isEmpty ? 0 : _total / _rows.length;
  int get _max => _rows.isEmpty
      ? 0
      : _rows.map((r) => r.cantidad).reduce((a, b) => a > b ? a : b);
  int get _min => _rows.isEmpty
      ? 0
      : _rows.map((r) => r.cantidad).reduce((a, b) => a < b ? a : b);

  @override
  Widget build(BuildContext context) {
    _state.ensureSeeded();

    return AppShell(
      currentRoute: AppRoutes.reportes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Generación de reportes',
            subtitle:
                'Genera reportes relacionados con las actividades de tu unidad avícola como producción de huevos, clasificación de huevos, mortalidad y morbilidad de las aves.',
          ),
          const SizedBox(height: 24),
          _filtersCard(),
          const SizedBox(height: 24),
          _resumenCard(),
          const SizedBox(height: 24),
          _comportamientoCard(),
          const SizedBox(height: 24),
          _detalleCard(),
        ],
      ),
    );
  }

  Widget _filtersCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros del reporte',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecciona los criterios para generar el reporte.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final fields = <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Tipo de reporte'),
                    DropdownButtonFormField<String>(
                      initialValue: _tipo,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: _tipoProduccion,
                          child: Text(_tipoProduccion),
                        ),
                        DropdownMenuItem(
                          value: _tipoClasificacion,
                          child: Text(_tipoClasificacion),
                        ),
                        DropdownMenuItem(
                          value: _tipoMortalidad,
                          child: Text(_tipoMortalidad),
                        ),
                        DropdownMenuItem(
                          value: _tipoMorbilidad,
                          child: Text(_tipoMorbilidad),
                        ),
                      ],
                      onChanged: (v) => setState(() => _tipo = v ?? _tipo),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Galpón'),
                    DropdownButtonFormField<String>(
                      initialValue: _galpon,
                      isExpanded: true,
                      items: [
                        for (final g in _galponOptions)
                          DropdownMenuItem(value: g, child: Text(g)),
                      ],
                      onChanged: (v) => setState(() => _galpon = v ?? _galpon),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Fecha de inicio'),
                    _dateField(_inicio, () => _pickDate(true)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Fecha de fin'),
                    _dateField(_fin, () => _pickDate(false)),
                  ],
                ),
              ];
              if (constraints.maxWidth < 780) {
                return Column(
                  children: [
                    for (final f in fields) ...[f, const SizedBox(height: 14)],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generar,
                        icon: const Icon(Icons.assessment_outlined, size: 18),
                        label: const Text('Generar reporte'),
                      ),
                    ),
                  ],
                );
              }
              if (constraints.maxWidth < 1100) {
                return Column(
                  children: [
                    for (var i = 0; i < fields.length; i += 2) ...[
                      Row(
                        children: [
                          Expanded(child: fields[i]),
                          const SizedBox(width: 16),
                          Expanded(child: fields[i + 1]),
                        ],
                      ),
                      if (i < fields.length - 2) const SizedBox(height: 14),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generar,
                        icon: const Icon(Icons.assessment_outlined, size: 18),
                        label: const Text('Generar reporte'),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < fields.length; i++) ...[
                        Expanded(child: fields[i]),
                        if (i < fields.length - 1) const SizedBox(width: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _generar,
                      icon: const Icon(Icons.assessment_outlined, size: 18),
                      label: const Text('Generar reporte'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dateField(DateTime? value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_month_outlined, size: 18),
        ),
        child: Text(
          value == null ? 'dd/mm/aaaa' : Formatters.date(value),
          style: TextStyle(color: value == null ? AppColors.textMuted : null),
        ),
      ),
    );
  }

  Widget _resumenCard() {
    final cards = [
      (
        'Registros',
        '${_rows.length}',
        Icons.description_outlined,
        AppColors.info,
      ),
      (
        'Total',
        Formatters.number(_total),
        Icons.calculate_outlined,
        AppColors.primary,
      ),
      (
        'Promedio',
        _promedio.toStringAsFixed(1),
        Icons.analytics_outlined,
        AppColors.emerald900,
      ),
      ('Máximo', '$_max', Icons.trending_up, AppColors.success),
      ('Mínimo', '$_min', Icons.trending_down, AppColors.warning),
    ];
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del reporte',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Indicadores obtenidos a partir de los datos seleccionados.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final c in cards)
                SizedBox(
                  width: 180,
                  child: StatCard(label: c.$1, value: c.$2, icon: c.$3),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comportamientoCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comportamiento del reporte',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 20),
          if (_rows.isEmpty)
            const SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  'No hay datos suficientes para generar el gráfico.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            SizedBox(height: 180, child: _SimpleBarChart(rows: _rows)),
        ],
      ),
    );
  }

  Widget _detalleCard() {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalle de registros',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Registros encontrados según los filtros seleccionados',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _rows.isEmpty ? null : _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: const Text('Exportar PDF'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_rows.isEmpty)
            const EmptyState(
              icon: Icons.table_chart_outlined,
              message: 'No hay datos para mostrar.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('FECHA')),
                  DataColumn(label: Text('GALPÓN')),
                  DataColumn(label: Text('CANTIDAD')),
                ],
                rows: [
                  for (final r in _rows)
                    DataRow(
                      cells: [
                        DataCell(Text(r.fecha)),
                        DataCell(Text(r.galpon)),
                        DataCell(Text(Formatters.number(r.cantidad))),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  const _SimpleBarChart({required this.rows});

  final List<ReportRow> rows;

  @override
  Widget build(BuildContext context) {
    final max = rows.map((r) => r.cantidad).reduce((a, b) => a > b ? a : b);
    final data = rows.take(12).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final r in data)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${r.cantidad}', style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 4),
                  Container(
                    height: max == 0
                        ? 4
                        : (120 * (r.cantidad / max)).clamp(4, 120),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r.fecha.length >= 5 ? r.fecha.substring(0, 5) : r.fecha,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
