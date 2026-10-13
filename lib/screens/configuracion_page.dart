import 'package:flutter/material.dart';

import '../data/app_state.dart';
import '../routes.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui.dart';

class ConfiguracionPage extends StatelessWidget {
  const ConfiguracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppRoutes.configuracion,
      child: SectionCard(
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final isDark = AppState.instance.themeMode == ThemeMode.dark;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preferencias de visualización',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: Theme.of(context).cardColor,
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tema oscuro'),
                    subtitle: const Text(
                      'Aplica el tema a todas las pantallas de AVISENA.',
                    ),
                    value: isDark,
                    onChanged: (enabled) => AppState.instance.setThemeMode(
                      enabled ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
