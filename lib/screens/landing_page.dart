import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../routes.dart';
import '../theme/app_theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _featuresKey = GlobalKey();
  final _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _LandingHeader(
              onFeaturesTap: () => _scrollTo(_featuresKey),
              onContactTap: () => _scrollTo(_contactKey),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.width >= 820 ? 88 : 32,
            ),
            const _HeroSection(),
            _FeaturesSection(key: _featuresKey),
            const _CtaSection(),
            _LandingFooter(key: _contactKey),
          ],
        ),
      ),
    );
  }
}

class _LandingHeader extends StatelessWidget {
  const _LandingHeader({
    required this.onFeaturesTap,
    required this.onContactTap,
  });

  final VoidCallback onFeaturesTap;
  final VoidCallback onContactTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 820;
    final isCompact = width < 420;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        border: const Border(bottom: BorderSide(color: Color(0xFFDCFCE7))),
      ),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 14),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/logo-sena-verde-complementario-svg-2022.svg',
            width: 44,
            height: 44,
          ),
          SizedBox(width: isWide ? 14 : 8),
          Expanded(
            child: Text(
              'AVISENA COL',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isWide ? 22 : 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          if (isWide) ...[
            _headerLink('Funcionalidades', onFeaturesTap),
            const SizedBox(width: 28),
            _headerLink('Acerca de nosotros', onFeaturesTap),
            const SizedBox(width: 28),
            _headerLink('Contáctanos', onContactTap),
            const SizedBox(width: 32),
          ],
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 22 : 14,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              elevation: 6,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            child: Text(isCompact ? 'Entrar' : 'Iniciar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _headerLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: SizedBox(
          height: isMobile ? 680 : 420,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/gallina_baner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Container(color: const Color(0xFF2C1D16)),
              ),
              Container(color: Colors.black.withValues(alpha: 0.45)),
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 720),
                  margin: const EdgeInsets.all(24),
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '¡Bienvenido!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 34 : 44,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Controla tu producción de huevos de forma eficiente.\n'
                        'Gestiona tus lotes y monitorea la salud de tus aves.\n'
                        '¡Tu éxito avícola a un toque de distancia!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: isMobile ? 15 : 17,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({super.key});

  static const List<List<String>> _features = [
    [
      'assets/images/icons8-grafico-combinado-50.png',
      'Control de Producción',
      'Registra y controla la producción diaria de huevos de forma rápida y organizada.',
    ],
    [
      'assets/images/icons8-test-fallido-50.png',
      'Clasificación',
      'Clasifica los huevos por tamaño, calidad y tipo para mejorar la gestión.',
    ],
    [
      'assets/images/icons8-corazon-con-pulso-50.png',
      'Mortalidad',
      'Lleva el control de aves fallecidas para análisis y toma de decisiones oportunas.',
    ],
    [
      'assets/images/icons8-alimentando-pollo-50.png',
      'Morbilidad',
      'Registra enfermedades y síntomas del lote.',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          const Text(
            'Todo lo que necesitas para tu galpón',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Text(
              'Nuestras herramientas digitales están diseñadas para mejorar la '
              'eficiencia operativa y el control total de tu producción desde la '
              'palma de tu mano.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00695C),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 700
                  ? 1
                  : constraints.maxWidth < 1100
                  ? 2
                  : 4;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: columns == 1 ? 1.0 : 1.05,
                children: [
                  for (final f in _features)
                    _FeatureCard(image: f[0], title: f[1], description: f[2]),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, _routeFor(widget.title)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -10 : 0, 0),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFFD1FAE5)),
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: Image.asset(
                    widget.image,
                    width: 44,
                    height: 44,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.egg_alt_outlined,
                      color: AppColors.emerald900,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF00695C),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 6,
                width: 64,
                decoration: BoxDecoration(
                  color: _hover ? AppColors.primaryHover : AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _routeFor(String title) {
    return switch (title) {
      'Control de Producción' => AppRoutes.produccion,
      'Clasificación' => AppRoutes.clasificacion,
      'Mortalidad' => AppRoutes.mortalidad,
      'Morbilidad' => AppRoutes.morbilidad,
      _ => AppRoutes.login,
    };
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.emerald900,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            const Text(
              '¿Listo para digitalizar tu granja?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                'Únete a cientos de productores que ya están optimizando sus '
                'resultados y aumentando su producción con tecnología de punta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              icon: const Icon(Icons.rocket_launch_outlined),
              label: const Text('Comenzar Ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingFooter extends StatelessWidget {
  const _LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(top: BorderSide(color: Color(0xFFD1FAE5))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/logo-sena-verde-complementario-svg-2022.svg',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              const Text(
                'AVISENA COL',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 28,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              Text(
                'Términos de Servicio',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                'Privacidad',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Text(
                'Soporte',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '© 2026 AVISENA COL. Innovación sostenible para la industria avícola.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.emerald900.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
