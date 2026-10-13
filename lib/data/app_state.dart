import 'package:flutter/material.dart';

import 'models.dart';

/// Single in-memory application store shared across all screens.
///
/// Mirrors the reference app's behaviour: every list starts with demo data
/// and every "add / edit / delete" action mutates the store so the whole UI
/// reacts immediately.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  // ---------------------------------------------------------------- session
  AppUserSession? _session;
  AppUserSession? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get isAdmin => _session?.role == AppRole.admin;

  ThemeMode themeMode = ThemeMode.light;

  void login(AppRole role) {
    _session = AppUserSession.forRole(role);
    if (users.isEmpty) _seedUsers();
    notifyListeners();
  }

  void logout() {
    _session = null;
    notifyListeners();
  }

  void updateProfile({required String name, required String email}) {
    final current = _session;
    if (current == null) return;
    _session = AppUserSession(
      role: current.role,
      name: name,
      email: email,
      avatarUrl: current.avatarUrl,
    );
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
  }

  // ------------------------------------------------------------ collections
  final List<StaffUser> users = [];
  final List<Lote> lotes = [];
  final List<ProduccionDiaria> producciones = [];
  final List<Clasificacion> clasificaciones = [];
  final List<Mortalidad> mortalidades = [];
  final List<Morbilidad> morbilidades = [];
  final List<Tratamiento> tratamientos = [];
  final List<TransaccionFinanciera> transacciones = [];
  final List<AppNotification> notificaciones = [];

  bool _seeded = false;

  /// Ensure demo data exists even when a screen is opened directly.
  void ensureSeeded() {
    if (_seeded) return;
    _seeded = true;
    _seedUsers();
    _seedLotes();
    _seedProduccion();
    _seedClasificacion();
    _seedMortalidad();
    _seedMorbilidad();
    _seedTratamientos();
    _seedFinanzas();
    _seedNotificaciones();
  }

  int _seq = 0;
  String _nextId(String prefix) {
    _seq++;
    return '$prefix-${_seq.toString().padLeft(4, '0')}';
  }

  // --------------------------------------------------------------- usuarios
  void _seedUsers() {
    if (users.isNotEmpty) return;
    final seed = [
      [
        'David Ruano',
        'david@sena.edu.co',
        '3001234567',
        '1001234567',
        'Instructor lider',
        'Pasto',
        '15/01/2026',
        true,
      ],
      [
        'Maria Rojas',
        'maria@sena.edu.co',
        '3109876543',
        '1009876543',
        'Instructor investigador',
        'Ipiales',
        '20/02/2026',
        true,
      ],
      [
        'Juan Perez',
        'juan@sena.edu.co',
        '3205554433',
        '1005554433',
        'Aprendiz de contrato',
        'Pasto',
        '01/03/2026',
        true,
      ],
      [
        'Ana Gómez',
        'ana@sena.edu.co',
        '3112223344',
        '1002223344',
        'Instructor lider',
        'Túquerres',
        '05/03/2026',
        false,
      ],
      [
        'Carlos Ruiz',
        'carlos@sena.edu.co',
        '3123334455',
        '1003334455',
        'Instructor investigador',
        'Pasto',
        '10/03/2026',
        true,
      ],
    ];
    for (final r in seed) {
      users.add(
        StaffUser(
          id: _nextId('USR'),
          name: r[0] as String,
          email: r[1] as String,
          phone: r[2] as String,
          document: r[3] as String,
          role: r[4] as String,
          residence: r[5] as String,
          joinDate: r[6] as String,
          active: r[7] as bool,
        ),
      );
    }
  }

  void addUser(StaffUser u) {
    users.add(u);
    notifyListeners();
  }

  void removeUser(String id) {
    users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  String nextUserId() => _nextId('USR');

  // ----------------------------------------------------------------- lotes
  void _seedLotes() {
    if (lotes.isNotEmpty) return;
    lotes.add(
      Lote(
        id: _nextId('LOT'),
        fechaIngreso: '12/04/2026',
        horaIngreso: '08:30 AM',
        galpon: 'Galpón A-1',
        pesoPromedio: '1.2 kg',
        semanasVida: 12,
        numAves: 5000,
        linea: 'Hy-Line Brown',
        responsable: 'David Ruano',
        certificados: true,
        informe: true,
      ),
    );
    lotes.add(
      Lote(
        id: _nextId('LOT'),
        fechaIngreso: '15/04/2026',
        horaIngreso: '09:00 AM',
        galpon: 'Galpón B-1',
        pesoPromedio: '0.8 kg',
        semanasVida: 8,
        numAves: 4500,
        linea: 'Lohmann Brown',
        responsable: 'Maria Rojas',
        certificados: true,
        informe: false,
      ),
    );
  }

  void addLote(Lote l) {
    lotes.add(l);
    notifyListeners();
  }

  void removeLote(String id) {
    lotes.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  String nextLoteId() => _nextId('LOT');

  List<String> get galpones {
    if (lotes.isEmpty) return const ['Galpón 01', 'Galpón 02'];
    return lotes.map((l) => l.galpon).toSet().toList();
  }

  // ------------------------------------------------------------ produccion
  void _seedProduccion() {
    if (producciones.isNotEmpty) return;
    producciones.add(
      ProduccionDiaria(
        id: _nextId('PRD'),
        fecha: Formatters.today(),
        galpon: 'Galpón 01',
        lote: 'Lote 2026-A',
        linea: 'Hy-Line Brown',
        edadSemanas: 22,
        buenos: 1180,
        rotos: 40,
        descarte: 20,
        trabajador: 'David Ruano',
        alimentoKg: 110,
      ),
    );
  }

  void addProduccion(ProduccionDiaria p) {
    producciones.add(p);
    notifyListeners();
  }

  void removeProduccion(String id) {
    producciones.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  String nextProduccionId() => _nextId('PRD');

  int get huevosHoy => producciones.fold(0, (a, p) => a + p.buenos);

  int get recoleccionesHoy => producciones.length;

  double get alimentoConsumidoHoy =>
      producciones.fold(0, (a, p) => a + p.alimentoKg);

  int get edadAvesActual =>
      producciones.isEmpty ? 0 : producciones.first.edadSemanas;

  String get galponMonitoreado =>
      producciones.isEmpty ? '--' : producciones.first.galpon;

  int get produccionEstimada => huevosHoy;

  double get puntajeCA {
    if (producciones.isEmpty) return 0;
    final total = producciones.fold(0, (a, p) => a + p.total);
    if (total == 0) return 0;
    return alimentoConsumidoHoy / (total / 12.0);
  }

  // -------------------------------------------------------- clasificaciones
  void _seedClasificacion() {
    // The reference shows an empty history by default.
  }

  void addClasificacion(Clasificacion c) {
    clasificaciones.insert(0, c);
    // Register the income produced by the classification.
    transacciones.insert(
      0,
      TransaccionFinanciera(
        id: _nextId('FIN'),
        fecha: c.fecha,
        galpon: c.galpon,
        concepto: 'Venta de clasificación (${c.produccionHoy} huevos)',
        categoria: CategoriaFinanciera.ventaHuevos,
        monto: c.totalDinero.toDouble(),
        estado: 'Completado',
      ),
    );
    notificaciones.insert(
      0,
      AppNotification(
        id: _nextId('NTF'),
        tipo: 'Producción',
        titulo: 'Nueva clasificación registrada',
        detalle: '${c.galpon}: ${c.produccionHoy} huevos clasificados.',
        fecha: 'Hace un momento',
        critica: false,
      ),
    );
    notifyListeners();
  }

  void removeClasificacion(String id) {
    clasificaciones.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  String nextClasificacionId() => _nextId('CLA');

  // ------------------------------------------------------------ mortalidad
  void _seedMortalidad() {}

  void addMortalidad(Mortalidad m) {
    mortalidades.insert(0, m);
    if (m.cantidad >= 20) {
      notificaciones.insert(
        0,
        AppNotification(
          id: _nextId('NTF'),
          tipo: 'Mortalidad',
          titulo: 'Alta Mortalidad: ${m.galpon}',
          detalle: 'Se registraron ${m.cantidad} bajas (${m.causa}).',
          fecha: 'Hace un momento',
          critica: true,
        ),
      );
    }
    _syncMortalidadGasto(m);
    notifyListeners();
  }

  void _syncMortalidadGasto(Mortalidad m) {
    transacciones.insert(
      0,
      TransaccionFinanciera(
        id: _nextId('FIN'),
        fecha: m.fecha,
        galpon: m.galpon,
        concepto: 'Manejo de mortalidad (${m.cantidad} aves)',
        categoria: CategoriaFinanciera.salud,
        monto: m.cantidad * 1500,
        estado: 'Pendiente',
      ),
    );
  }

  void removeMortalidad(String id) {
    mortalidades.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  String nextMortalidadId() => _nextId('MOR');

  int get mortalidadTotalMes => mortalidades.fold(0, (a, m) => a + m.cantidad);

  String get causaPrincipalMortalidad {
    if (mortalidades.isEmpty) return '--';
    final counts = <String, int>{};
    for (final m in mortalidades) {
      counts[m.causa] = (counts[m.causa] ?? 0) + m.cantidad;
    }
    final top = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key;
  }

  double get tasaMortalidad {
    final aves = lotes.fold(0, (a, l) => a + l.numAves);
    if (aves == 0) return 0;
    return (mortalidadTotalMes / aves) * 100;
  }

  // ------------------------------------------------------------- morbilidad
  void _seedMorbilidad() {}

  void addMorbilidad(Morbilidad m) {
    morbilidades.insert(0, m);
    notificaciones.insert(
      0,
      AppNotification(
        id: _nextId('NTF'),
        tipo: 'Morbilidad',
        titulo: 'Nuevo caso de morbilidad en ${m.lote}',
        detalle: m.sintomas,
        fecha: 'Hace un momento',
        critica: m.afectacion.toLowerCase().contains('alta'),
      ),
    );
    notifyListeners();
  }

  void removeMorbilidad(String id) {
    morbilidades.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  String nextMorbilidadId() => _nextId('MRB');

  // ------------------------------------------------------------ tratamiento
  void _seedTratamientos() {}

  void addTratamiento(Tratamiento t) {
    tratamientos.insert(0, t);
    notifyListeners();
  }

  void removeTratamiento(String id) {
    tratamientos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  String nextTratamientoId() => _nextId('TRT');

  // ---------------------------------------------------------------- finanzas
  void _seedFinanzas() {}

  void addTransaccion(TransaccionFinanciera t) {
    transacciones.insert(0, t);
    notifyListeners();
  }

  void removeTransaccion(String id) {
    transacciones.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  String nextTransaccionId() => _nextId('FIN');

  double get ingresosVentas =>
      transacciones.where((t) => t.isIngreso).fold(0, (a, t) => a + t.monto);

  double get gastosOperativos =>
      transacciones.where((t) => !t.isIngreso).fold(0, (a, t) => a + t.monto);

  double get utilidadNeta => ingresosVentas - gastosOperativos;

  double get viabilidad {
    if (ingresosVentas == 0) return 0;
    final ratio = utilidadNeta / ingresosVentas;
    return (ratio * 100).clamp(-100, 100);
  }

  /// Poultry sold per type key (from classifications).
  Map<String, int> get panalesVendidos {
    final map = {for (final k in Clasificacion.tipoKeys) k: 0};
    for (final c in clasificaciones) {
      c.tipos.forEach((k, v) => map[k] = (map[k] ?? 0) + v);
    }
    return map;
  }

  Map<CategoriaFinanciera, double> get gastoPorCategoria {
    final map = <CategoriaFinanciera, double>{};
    for (final t in transacciones.where((t) => !t.isIngreso)) {
      map[t.categoria] = (map[t.categoria] ?? 0) + t.monto;
    }
    return map;
  }

  // --------------------------------------------------------- notificaciones
  void _seedNotificaciones() {
    if (notificaciones.isNotEmpty) return;
    notificaciones.addAll([
      AppNotification(
        id: _nextId('NTF'),
        tipo: 'Mortalidad',
        titulo: 'Alta Mortalidad: Galpón 4',
        detalle: 'El índice ha superado el umbral del 2%.',
        fecha: 'Hace 5 min',
        critica: true,
      ),
      AppNotification(
        id: _nextId('NTF'),
        tipo: 'Producción',
        titulo: 'Producción: Incremento del 5%',
        detalle: 'Recolección optimizada en Lote 2026-B.',
        fecha: 'Hace 12 min',
        critica: false,
      ),
      AppNotification(
        id: _nextId('NTF'),
        tipo: 'Inventario',
        titulo: 'Silo A: Nivel Bajo (15%)',
        detalle: 'Se requiere pedido de reposición inmediato.',
        fecha: 'Hace 1 hora',
        critica: true,
      ),
      AppNotification(
        id: _nextId('NTF'),
        tipo: 'Ambiente',
        titulo: 'Temp Crítica: Galpón 2 (32°C)',
        detalle: 'Extractores activados automáticamente.',
        fecha: 'Hace 5 horas',
        critica: false,
      ),
    ]);
  }

  void markNotificationRead(String id) {
    final n = notificaciones.firstWhere((n) => n.id == id);
    n.leida = true;
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (final n in notificaciones) {
      n.leida = true;
    }
    notifyListeners();
  }

  void removeNotificacion(String id) {
    notificaciones.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  int get unreadNotifications => notificaciones.where((n) => !n.leida).length;
  int get criticalNotifications =>
      notificaciones.where((n) => n.critica).length;

  // ------------------------------------------------------- dashboard metrics
  int get usuariosActivos => users.where((u) => u.active).length;
  int get usuariosInhabilitados => users.where((u) => !u.active).length;

  int get reportesSemanales =>
      producciones.length +
      clasificaciones.length +
      mortalidades.length +
      morbilidades.length;

  int get alertasAlimento =>
      notificaciones.where((n) => n.tipo == 'Inventario').length;

  int get saludSistema {
    final base = 100 - criticalNotifications * 2;
    return base.clamp(0, 100);
  }
}
