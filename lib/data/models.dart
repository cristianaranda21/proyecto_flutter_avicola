import 'package:flutter/material.dart';

/// Application roles. The reference app exposes three roles.
enum AppRole {
  admin('Instructor Líder', 'Instructor Líder (Admin)'),
  aprendiz('Aprendiz de Contrato', 'Aprendiz Sena'),
  investigador('Instructor Investigador', 'Instructor Investigador');

  const AppRole(this.label, this.displayName);
  final String label;
  final String displayName;

  static AppRole fromKey(String key) {
    switch (key) {
      case 'aprendiz':
        return AppRole.aprendiz;
      case 'investigador':
        return AppRole.investigador;
      default:
        return AppRole.admin;
    }
  }

  String get key => name;
}

class AppUserSession {
  const AppUserSession({
    required this.role,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final AppRole role;
  final String name;
  final String email;
  final String avatarUrl;

  static AppUserSession forRole(AppRole role) {
    switch (role) {
      case AppRole.admin:
        return const AppUserSession(
          role: AppRole.admin,
          name: 'Instructor Líder (Admin)',
          email: 'admin.lider@granja.com',
          avatarUrl:
              'https://ui-avatars.com/api/?name=Instructor+Lider&background=5be830&color=fff',
        );
      case AppRole.aprendiz:
        return const AppUserSession(
          role: AppRole.aprendiz,
          name: 'Aprendiz Sena',
          email: 'aprendiz.sena@granja.com',
          avatarUrl:
              'https://ui-avatars.com/api/?name=Aprendiz+Sena&background=0284c7&color=fff',
        );
      case AppRole.investigador:
        return const AppUserSession(
          role: AppRole.investigador,
          name: 'Instructor Investigador',
          email: 'investigador.sena@granja.com',
          avatarUrl:
              'https://ui-avatars.com/api/?name=Instructor+Investigador&background=f59e0b&color=fff',
        );
    }
  }
}

/// A staff member (Gestión de Usuarios).
class StaffUser {
  StaffUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.document,
    required this.role,
    required this.residence,
    required this.joinDate,
    this.active = true,
  });

  final String id;
  String name;
  String email;
  String phone;
  String document;
  String role;
  String residence;
  String joinDate;
  bool active;
}

/// A galpón / lote (Administrar lotes).
class Lote {
  Lote({
    required this.id,
    required this.fechaIngreso,
    required this.horaIngreso,
    required this.galpon,
    required this.pesoPromedio,
    required this.semanasVida,
    required this.numAves,
    required this.linea,
    required this.responsable,
    this.certificados = false,
    this.informe = false,
  });

  final String id;
  String fechaIngreso;
  String horaIngreso;
  String galpon;
  String pesoPromedio;
  int semanasVida;
  int numAves;
  String linea;
  String responsable;
  bool certificados;
  bool informe;
}

/// Daily production record (Producción Diaria).
class ProduccionDiaria {
  ProduccionDiaria({
    required this.id,
    required this.fecha,
    required this.galpon,
    required this.lote,
    required this.linea,
    required this.edadSemanas,
    required this.buenos,
    required this.rotos,
    required this.descarte,
    required this.trabajador,
    this.alimentoKg = 0,
  });

  final String id;
  String fecha;
  String galpon;
  String lote;
  String linea;
  int edadSemanas;
  int buenos;
  int rotos;
  int descarte;
  String trabajador;
  double alimentoKg;

  int get total => buenos + rotos + descarte;
}

/// Egg classification (Clasificación Huevos).
class Clasificacion {
  Clasificacion({
    required this.id,
    required this.fecha,
    required this.galpon,
    required this.tipos,
    required this.sobrantesSiguiente,
    required this.responsable,
  });

  final String id;
  String fecha;
  String galpon;

  /// Count per egg type key: C, B, A, AA, AAA, Jumbo.
  Map<String, int> tipos;
  int sobrantesSiguiente;
  String responsable;

  static const List<String> tipoKeys = ['C', 'B', 'A', 'AA', 'AAA', 'Jumbo'];
  static const Map<String, double> precios = {
    'C': 10500,
    'B': 12000,
    'A': 13500,
    'AA': 15000,
    'AAA': 16500,
    'Jumbo': 18000,
  };

  int get produccionHoy => tipos.values.fold(0, (a, b) => a + b);

  int get totalDinero {
    var total = 0.0;
    for (final entry in tipos.entries) {
      total += (precios[entry.key] ?? 0) * entry.value;
    }
    return total.round();
  }
}

/// Avian mortality record (Mortalidad).
class Mortalidad {
  Mortalidad({
    required this.id,
    required this.fecha,
    required this.galpon,
    required this.cantidad,
    required this.edadSemanas,
    required this.causa,
    required this.necropsia,
    required this.disposicion,
  });

  final String id;
  String fecha;
  String galpon;
  int cantidad;
  int edadSemanas;
  String causa;
  String necropsia;
  String disposicion;
}

/// Morbidity record (Morbilidad).
class Morbilidad {
  Morbilidad({
    required this.id,
    required this.fecha,
    required this.lote,
    required this.sintomas,
    required this.afectacion,
    required this.accion,
    required this.responsable,
    required this.tratamiento,
  });

  final String id;
  String fecha;
  String lote;
  String sintomas;
  String afectacion;
  String accion;
  String responsable;
  String tratamiento;
}

/// Treatment record (Tratamiento).
class Tratamiento {
  Tratamiento({
    required this.id,
    required this.medicamento,
    required this.tipo,
    required this.ubicacion,
    required this.via,
    required this.inicio,
    required this.duracion,
    required this.diagnostico,
    required this.responsable,
    required this.estado,
  });

  final String id;
  String medicamento;
  String tipo;
  String ubicacion;
  String via;
  String inicio;
  String duracion;
  String diagnostico;
  String responsable;
  String estado;
}

enum CategoriaFinanciera {
  ventaHuevos('Venta de Huevos', true),
  alimentos('Alimentos', false),
  salud('Salud y Vacunas', false),
  infraestructura('Infraestructura', false);

  const CategoriaFinanciera(this.label, this.isIngreso);
  final String label;
  final bool isIngreso;
}

/// Financial movement (Finanzas).
class TransaccionFinanciera {
  TransaccionFinanciera({
    required this.id,
    required this.fecha,
    required this.galpon,
    required this.concepto,
    required this.categoria,
    required this.monto,
    required this.estado,
  });

  final String id;
  String fecha;
  String galpon;
  String concepto;
  CategoriaFinanciera categoria;
  double monto;
  String estado;

  bool get isIngreso => categoria.isIngreso;
}

/// Notification (Centro de Notificaciones).
class AppNotification {
  AppNotification({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.detalle,
    required this.fecha,
    required this.critica,
    this.leida = false,
  });

  final String id;
  String tipo;
  String titulo;
  String detalle;
  String fecha;
  bool critica;
  bool leida;
}

/// A single report data row produced by the report generator.
class ReportRow {
  const ReportRow({required this.fecha, required this.galpon, required this.cantidad});
  final String fecha;
  final String galpon;
  final int cantidad;
}

/// Reusable formatting helpers.
class Formatters {
  Formatters._();

  static String currency(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '\$${buffer.toString()}';
  }

  static String number(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String today() {
    return date(DateTime.now());
  }

  static String date(DateTime value) {
    return '${_two(value.day)}/${_two(value.month)}/${value.year}';
  }

  static String nowTime() {
    final now = DateTime.now();
    return '${_two(now.hour)}:${_two(now.minute)}';
  }

  static String _two(int v) => v < 10 ? '0$v' : '$v';
}

/// Common egg-type colors used across classification / finances.
const Map<String, Color> kEggTypeColors = {
  'C': Color(0xFF94A3B8),
  'B': Color(0xFF0EA5E9),
  'A': Color(0xFF22C55E),
  'AA': Color(0xFFF59E0B),
  'AAA': Color(0xFF8B5CF6),
  'Jumbo': Color(0xFFEF4444),
};
