import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class FinanzasPage extends StatefulWidget {
  const FinanzasPage({super.key});

  @override
  State<FinanzasPage> createState() => _FinanzasPageState();
}

class _FinanzasPageState extends State<FinanzasPage> {
  AppState get _state => AppState.instance;

  @override
  Widget build(BuildContext context) {
    _state.ensureSeeded();

    return AppShell(
      currentRoute: AppRoutes.finanzas,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wide
                  ? Row(
                      children: [
                        Expanded(child: _summaryCards()),
                        const SizedBox(width: 16),
                        _registrarButton(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _summaryCards(),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _registrarButton(),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),
              _flujoCard(),
              const SizedBox(height: 24),
              _categoriasRow(),
              const SizedBox(height: 24),
              _clasificacionCard(),
              const SizedBox(height: 24),
              _historialCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _registrarButton() {
    return Builder(
      builder: (ctx) => ElevatedButton.icon(
        onPressed: () => _showAddDialog(ctx),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Registrar Operación'),
      ),
    );
  }

  Widget _summaryCards() {
    final cards = [
      (
        'Ingresos de Ventas',
        Formatters.currency(_state.ingresosVentas),
        AppColors.success,
      ),
      (
        'Gastos Operativos',
        Formatters.currency(_state.gastosOperativos),
        AppColors.danger,
      ),
      (
        'Utilidad Neta',
        Formatters.currency(_state.utilidadNeta),
        AppColors.emerald900,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                _summaryCard(cards[i]),
                if (i < cards.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              Expanded(child: _summaryCard(cards[i])),
              if (i < cards.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _summaryCard((String, String, Color) c) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.$1, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Text(
            c.$2,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: c.$3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _flujoCard() {
    final compact = MediaQuery.sizeOf(context).width < 600;
    const months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];
    final incomeByMonth = List<double>.filled(12, 0);
    final expenseByMonth = List<double>.filled(12, 0);
    for (final t in _state.transacciones) {
      final d = _parse(t.fecha);
      final monthIndex = d == null ? 0 : d.month - 1;
      if (t.isIngreso) {
        incomeByMonth[monthIndex] += t.monto;
      } else {
        expenseByMonth[monthIndex] += t.monto;
      }
    }
    final maxValue = [
      ...incomeByMonth,
      ...expenseByMonth,
    ].fold<double>(0, (a, b) => a > b ? a : b);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flujo de Efectivo Mensual',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 12; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _bar(
                                incomeByMonth[i],
                                maxValue,
                                AppColors.success,
                                compact: compact,
                              ),
                              const SizedBox(width: 3),
                              _bar(
                                expenseByMonth[i],
                                maxValue,
                                AppColors.danger,
                                compact: compact,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            months[i],
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _state.transacciones.isEmpty
                      ? 'Viabilidad Financiera: Sin movimientos registrados'
                      : 'Viabilidad Financiera: ${_state.viabilidad.toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(double value, double max, Color color, {required bool compact}) {
    final h = max == 0 ? 2.0 : (100 * (value / max)).clamp(2.0, 100.0);
    return Container(
      width: compact ? 7 : 10,
      height: h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _categoriasRow() {
    final gastos = _state.gastoPorCategoria;
    final totalGastos = _state.gastosOperativos;
    final cards = <Widget>[];
    for (final cat in [
      CategoriaFinanciera.ventaHuevos,
      CategoriaFinanciera.alimentos,
      CategoriaFinanciera.salud,
      CategoriaFinanciera.infraestructura,
    ]) {
      double value;
      if (cat == CategoriaFinanciera.ventaHuevos) {
        value = _state.ingresosVentas;
      } else {
        value = gastos[cat] ?? 0.0;
      }
      final base = cat.isIngreso ? _state.ingresosVentas : totalGastos;
      final pct = base == 0 ? 0.0 : (value / base * 100);
      cards.add(_categoryCard(cat, value, pct));
    }
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
          childAspectRatio: columns == 1 ? 2.8 : 1.7,
          children: cards,
        );
      },
    );
  }

  Widget _categoryCard(CategoriaFinanciera cat, double value, double pct) {
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cat.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(value),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _clasificacionCard() {
    final vendidos = _state.panalesVendidos;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clasificación (Tipo)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('TIPO')),
                DataColumn(label: Text('PANAL VENDIDO')),
                DataColumn(label: Text('PRECIO PANAL')),
                DataColumn(label: Text('TOTAL INGRESOS')),
              ],
              rows: [
                for (final k in Clasificacion.tipoKeys)
                  DataRow(
                    cells: [
                      DataCell(
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
                            const SizedBox(width: 8),
                            Text(
                              'Tipo $k',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text('${vendidos[k] ?? 0} pnl')),
                      DataCell(
                        Text(
                          Formatters.currency(Clasificacion.precios[k] ?? 0),
                        ),
                      ),
                      DataCell(
                        Text(
                          Formatters.currency(
                            (vendidos[k] ?? 0) *
                                (Clasificacion.precios[k] ?? 0),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
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

  Widget _historialCard() {
    final items = _state.transacciones;
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Historial Financiero',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              message:
                  'No hay registros financieros que coincidan con la búsqueda.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('FECHA / GALPÓN')),
                  DataColumn(label: Text('CONCEPTO')),
                  DataColumn(label: Text('CATEGORÍA')),
                  DataColumn(label: Text('MONTO')),
                  DataColumn(label: Text('ESTADO')),
                  DataColumn(label: Text('ACCIONES')),
                ],
                rows: [
                  for (final t in items)
                    DataRow(
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t.fecha,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                t.galpon,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(t.concepto)),
                        DataCell(
                          StatusChip(
                            label: t.categoria.label,
                            color: t.isIngreso
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        DataCell(
                          Text(
                            (t.isIngreso ? '+' : '-') +
                                Formatters.currency(t.monto),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: t.isIngreso
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                        DataCell(
                          StatusChip(
                            label: t.estado,
                            color: t.estado == 'Completado'
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        DataCell(
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            onPressed: () => _state.removeTransaccion(t.id),
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

  DateTime? _parse(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  void _showAddDialog(BuildContext context) {
    final state = AppState.instance;
    final concepto = TextEditingController();
    final galpon = TextEditingController(text: state.galpones.first);
    final monto = TextEditingController();
    CategoriaFinanciera categoria = CategoriaFinanciera.ventaHuevos;
    String estado = 'Completado';

    showFormDialog(
      context,
      title: 'Registrar Operación',
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Categoría', required: true),
            DropdownButtonFormField<CategoriaFinanciera>(
              initialValue: categoria,
              items: [
                for (final c in CategoriaFinanciera.values)
                  DropdownMenuItem(
                    value: c,
                    child: Text(
                      '${c.label} (${c.isIngreso ? 'Ingreso' : 'Gasto'})',
                    ),
                  ),
              ],
              onChanged: (v) =>
                  setDialogState(() => categoria = v ?? categoria),
            ),
            const SizedBox(height: 14),
            const FieldLabel('Concepto', required: true),
            TextField(controller: concepto),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Galpón'),
                      TextField(controller: galpon),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel('Monto', required: true),
                      TextField(
                        controller: monto,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(prefixText: '\$ '),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const FieldLabel('Estado'),
            DropdownButtonFormField<String>(
              initialValue: estado,
              items: const [
                DropdownMenuItem(
                  value: 'Completado',
                  child: Text('Completado'),
                ),
                DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
              ],
              onChanged: (v) => setDialogState(() => estado = v ?? estado),
            ),
          ],
        ),
      ),
      onSave: () {
        final value = double.tryParse(monto.text.trim()) ?? 0;
        if (value <= 0 || concepto.text.trim().isEmpty) {
          showAppSnackBar(
            context,
            'Ingresa un concepto y un monto válidos',
            error: true,
          );
          return;
        }
        state.addTransaccion(
          TransaccionFinanciera(
            id: state.nextTransaccionId(),
            fecha: Formatters.today(),
            galpon: galpon.text.trim(),
            concepto: concepto.text.trim(),
            categoria: categoria,
            monto: value,
            estado: estado,
          ),
        );
        showAppSnackBar(context, 'Operación registrada');
      },
    );
  }
}
