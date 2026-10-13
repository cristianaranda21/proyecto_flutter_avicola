import 'package:flutter/material.dart';

import '../routes.dart';
import '../theme/app_theme.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String title;

  const DashboardShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(title),
              actions: [_buildUserInfoRow(), const SizedBox(width: 16)],
            ),
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildTopHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: child,
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _buildUserInfoRow(),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow() {
    return Row(
      children: [
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Instructor Líder',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Admin',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Stack(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.textDark,
              child: Icon(Icons.person, color: Colors.white),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(child: _buildSidebarContent(context));
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: _buildSidebarContent(context),
    );
  }

  Widget _buildSidebarContent(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              const Icon(Icons.agriculture, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Text(
                'AVISENA',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildNavItem(context, 'Inicio', Icons.home, '/dashboard'),
              _buildNavItem(
                context,
                'Gestión de Usuarios',
                Icons.people,
                '/users',
              ),
              _buildNavItem(
                context,
                'Administrar lotes',
                Icons.inventory_2,
                '/lotes',
              ),
              _buildNavItem(
                context,
                'Registros',
                Icons.assignment,
                '/registros',
                isExpandable: true,
              ),
              _buildNavItem(
                context,
                'Reportes',
                Icons.description,
                '/reportes',
              ),
              _buildNavItem(
                context,
                'Finanzas',
                Icons.attach_money,
                '/finanzas',
              ),
              _buildNavItem(
                context,
                'Notificaciones',
                Icons.notifications,
                '/notificaciones',
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.login),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    String route, {
    bool isExpandable = false,
  }) {
    final isActive = currentRoute == route;

    if (isExpandable) {
      return ExpansionTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 54, right: 16),
            title: const Text('Producción'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.produccion),
          ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 54, right: 16),
            title: const Text('Mortalidad'),
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.mortalidad),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.backgroundLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.emerald900 : Colors.black54,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.emerald900 : Colors.black87,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          if (!isActive) {
            Navigator.pushReplacementNamed(context, route);
          } else {
            if (Scaffold.of(context).isDrawerOpen) {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const Text(
        '© 2026 Sistema de Gestión Avícola. SENA.',
        style: TextStyle(color: Colors.black54, fontSize: 12),
      ),
    );
  }
}
