/// Route names mirroring the reference app's URLs.
class AppRoutes {
  AppRoutes._();

  static const String landing = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String lotes = '/lotes';
  static const String produccion = '/prodfunfinal';
  static const String clasificacion = '/registro_clasificacion';
  static const String mortalidad = '/mortalidad';
  static const String morbilidad = '/morbilidad';
  static const String tratamiento = '/tratamiento';
  static const String reportes = '/reportes';
  static const String finanzas = '/finanzas';
  static const String notificaciones = '/notificaciones';
  static const String profile = '/profile';
  static const String configuracion = '/configuracion';

  /// Page titles used by the shell header (matches the reference map).
  static const Map<String, String> titles = {
    dashboard: 'Inicio',
    users: 'Gestión de Usuarios',
    lotes: 'Administrar lotes',
    produccion: 'Producción Diaria',
    clasificacion: 'Clasificación de Huevos',
    mortalidad: 'Mortalidad',
    morbilidad: 'Morbilidad',
    tratamiento: 'Tratamiento',
    reportes: 'Reportes',
    finanzas: 'Finanzas',
    notificaciones: 'Notificaciones',
    profile: 'Mi Perfil',
    configuracion: 'Configuración',
  };

  static const List<String> registroRoutes = [
    produccion,
    clasificacion,
    mortalidad,
    morbilidad,
    tratamiento,
  ];
}
