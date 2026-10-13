import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/app_state.dart';
import '../data/models.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

/// Framed dashboard layout: collapsible sidebar + top bar + scrollable body.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.currentRoute, required this.child});

  final String currentRoute;
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _collapsed = false;
  bool _registrosOpen = false;

  AppState get _state => AppState.instance;

  bool get _registrosActive =>
      AppRoutes.registroRoutes.contains(widget.currentRoute);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: isDesktop ? null : _buildMobileAppBar(),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(isDrawer: true)),
      body: SafeArea(
        top: false,
        child: Row(
          children: [
            if (isDesktop) _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(isDesktop: isDesktop),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isDesktop ? 32 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [widget.child, const _ShellFooter()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      title: Text(AppRoutes.titles[widget.currentRoute] ?? 'AVISENA'),
      actions: const [
        _NotificationBell(),
        SizedBox(width: 8),
        _UserAvatarMenu(compact: true),
        SizedBox(width: 12),
      ],
    );
  }

  Widget _buildTopBar({required bool isDesktop}) {
    final theme = Theme.of(context);
    final title = AppRoutes.titles[widget.currentRoute] ?? 'AVISENA';
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (isDesktop) ...[
            const _NotificationBell(),
            const SizedBox(width: 20),
            const _UserAvatarMenu(),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebar({bool isDrawer = false}) {
    final theme = Theme.of(context);
    final width = isDrawer ? 280.0 : (_collapsed ? 84.0 : 264.0);
    final collapsed = _collapsed && !isDrawer;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          _SidebarHeader(collapsed: collapsed),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _navItem(
                  'Inicio',
                  Icons.home_outlined,
                  AppRoutes.dashboard,
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                if (_state.isAdmin)
                  _navItem(
                    'Gestión de Usuarios',
                    Icons.people_outline,
                    AppRoutes.users,
                    collapsed: collapsed,
                    isDrawer: isDrawer,
                  ),
                _navItem(
                  'Administrar lotes',
                  Icons.inventory_2_outlined,
                  AppRoutes.lotes,
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                _registrosDropdown(collapsed),
                _navItem(
                  'Reportes',
                  Icons.description_outlined,
                  AppRoutes.reportes,
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                ),
                if (_state.isAdmin)
                  _navItem(
                    'Finanzas',
                    Icons.attach_money_outlined,
                    AppRoutes.finanzas,
                    collapsed: collapsed,
                    isDrawer: isDrawer,
                  ),
                _navItem(
                  'Notificaciones',
                  Icons.notifications_outlined,
                  AppRoutes.notificaciones,
                  collapsed: collapsed,
                  isDrawer: isDrawer,
                  badge: _state.unreadNotifications,
                ),
              ],
            ),
          ),
          if (!isDrawer) _buildCollapseToggle(),
        ],
      ),
    );
  }

  Widget _buildCollapseToggle() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextButton.icon(
        onPressed: () => setState(() => _collapsed = !_collapsed),
        icon: Icon(
          _collapsed
              ? Icons.keyboard_double_arrow_right
              : Icons.keyboard_double_arrow_left,
          size: 18,
        ),
        label: _collapsed ? const SizedBox.shrink() : const Text('Ocultar'),
        style: TextButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
          foregroundColor: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _navItem(
    String label,
    IconData icon,
    String route, {
    required bool collapsed,
    bool isDrawer = false,
    int badge = 0,
  }) {
    final theme = Theme.of(context);
    final active = widget.currentRoute == route;
    final fg = active ? AppColors.primary : theme.textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          if (isDrawer) Navigator.pop(context);
          if (!active) Navigator.pushReplacementNamed(context, route);
        },
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 14),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: fg),
              if (!collapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _registrosDropdown(bool collapsed) {
    final theme = Theme.of(context);
    final active = _registrosActive;

    if (collapsed) {
      return _navItem(
        'Registros',
        Icons.assignment_outlined,
        AppRoutes.produccion,
        collapsed: true,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: () => setState(() => _registrosOpen = !_registrosOpen),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 20,
                    color: active
                        ? AppColors.primary
                        : theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Registros',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                        color: active ? AppColors.primary : null,
                      ),
                    ),
                  ),
                  Icon(
                    _registrosOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                _subItem('Producción Diaria', AppRoutes.produccion),
                _subItem('Clasificación Huevos', AppRoutes.clasificacion),
                _subItem('Mortalidad', AppRoutes.mortalidad),
                _subItem('Morbilidad', AppRoutes.morbilidad),
                _subItem('Tratamiento', AppRoutes.tratamiento),
              ],
            ),
            crossFadeState: _registrosOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _subItem(String label, String route) {
    final theme = Theme.of(context);
    final active = widget.currentRoute == route;
    return InkWell(
      onTap: () {
        if (!active) Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(left: 48, top: 8, bottom: 8, right: 12),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: active
                ? AppColors.primary
                : theme.textTheme.bodySmall?.color,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = AppState.instance.session?.role.label ?? 'Instructor Líder';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: collapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: SvgPicture.asset(
              'assets/images/logo-sena-verde-complementario-svg-2022.svg',
              width: 32,
              height: 32,
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AVISENA',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final unread = AppState.instance.unreadNotifications;
    return Stack(
      children: [
        IconButton(
          tooltip: 'Notificaciones',
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.notificaciones),
          icon: const Icon(Icons.notifications_outlined),
        ),
        if (unread > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UserAvatarMenu extends StatelessWidget {
  const _UserAvatarMenu({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session =
        AppState.instance.session ?? AppUserSession.forRole(AppRole.admin);

    return PopupMenuButton<String>(
      tooltip: 'Cuenta',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(session.email, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'profile',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person_outline),
            title: Text('Mi Perfil'),
          ),
        ),
        const PopupMenuItem(
          value: 'config',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined),
            title: Text('Configuración'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout, color: AppColors.danger),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
            break;
          case 'config':
            Navigator.pushReplacementNamed(context, AppRoutes.configuracion);
            break;
          case 'logout':
            AppState.instance.logout();
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (r) => false,
            );
            break;
        }
      },
      child: Row(
        children: [
          if (!compact) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  session.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
          ],
          CircleAvatar(
            radius: compact ? 16 : 20,
            backgroundColor: AppColors.primary,
            child: Text(
              session.name.isEmpty ? '?' : session.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellFooter extends StatelessWidget {
  const _ShellFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text('Sistema de Gestión Avicola', style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            '© 2026 AVISENA COL',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
