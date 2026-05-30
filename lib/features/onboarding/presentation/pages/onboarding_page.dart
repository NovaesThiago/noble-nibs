import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noble_nibs/core/providers/app_flags_provider.dart';
import 'package:noble_nibs/core/theme/app_colors.dart';
import 'package:noble_nibs/core/theme/app_dimensions.dart';
import 'package:noble_nibs/core/theme/app_typography.dart';
import 'package:noble_nibs/core/widgets/app_button.dart';
import 'package:noble_nibs/core/widgets/bean_pattern_background.dart';

class _Slide {
  const _Slide(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

/// Onboarding em 3 telas, exibido apenas no primeiro acesso.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(Icons.travel_explore_rounded, 'Origens selecionadas',
        'Grãos de microlotes do Brasil ao Panamá, com rastreabilidade e história.'),
    _Slide(Icons.local_fire_department_rounded, 'Torra artesanal',
        'Torrados em pequenos lotes, no ponto ideal para cada perfil sensorial.'),
    _Slide(Icons.local_shipping_rounded, 'Fresco até você',
        'Moído na hora, na moagem que preferir, entregue na sua porta.'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(onboardingSeenProvider.notifier).markSeen();
    widget.onDone?.call();
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BeanPatternBackground(opacity: 0.05)),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Pular', style: AppTypography.label.copyWith(letterSpacing: 0)),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    itemCount: _slides.length,
                    itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                  ),
                ),
                _Dots(count: _slides.length, active: _page),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: AppButton.primary(
                    isLast ? 'Começar' : 'Próximo',
                    icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                    onPressed: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.caramel, AppColors.caramelDeep],
                center: Alignment(-0.3, -0.4),
              ),
              boxShadow: AppShadows.card,
            ),
            child: Icon(slide.icon, size: 72, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(slide.title, textAlign: TextAlign.center, style: AppTypography.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpacing.md),
          Text(slide.body, textAlign: TextAlign.center, style: AppTypography.body.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active ? AppColors.caramel : AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}
