import 'package:bara_alsalfa/core/widgets/bara_button.dart';
import 'package:bara_alsalfa/core/widgets/bara_scaffold.dart';
import 'package:bara_alsalfa/core/widgets/glow_card.dart';
import 'package:bara_alsalfa/core/i18n/ui_phrase_localizer.dart';
import 'package:bara_alsalfa/features/home/presentation/home_screen.dart';
import 'package:bara_alsalfa/features/profile/presentation/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const routePath = '/onboarding';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    (
      title: 'واحد منكم برا السالفة',
      body: 'كل اللاعبين يشوفون نفس الموضوع، إلا لاعب واحد لازم يندمج بسرعة.',
      icon: Icons.visibility_off_rounded,
    ),
    (
      title: 'مرّر الجوال بسرية',
      body: 'كل لاعب يمسك الجهاز لحاله ويضغط مطولًا حتى يعرف دوره أو كلمته.',
      icon: Icons.pan_tool_alt_rounded,
    ),
    (
      title: 'ناقشوا ثم صوّتوا',
      body: 'بعد جولة التلميحات يبدأ الشك، وفي النهاية تصويت واحد يفضح الحقيقة.',
      icon: Icons.how_to_vote_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    warmUiPhrases(
      ref,
      [
        for (final slide in _slides) ...[slide.title, slide.body],
        'تخطي',
        'ابدأ اللعب',
        'التالي',
      ],
    );
    return BaraScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await ref.read(appSettingsProvider.notifier).completeOnboarding();
                  if (context.mounted) {
                    context.go(HomeScreen.routePath);
                  }
                },
                child: Text(localizeUiPhrase(ref, 'تخطي')),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => _page = value),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Center(
                    child: GlowCard(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(slide.icon, size: 64, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 24),
                          Text(
                            localizeUiPhrase(ref, slide.title),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizeUiPhrase(ref, slide.body),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            BaraButton.primary(
              label: _page == _slides.length - 1
                  ? localizeUiPhrase(ref, 'ابدأ اللعب')
                  : localizeUiPhrase(ref, 'التالي'),
              icon: Icons.arrow_back_rounded,
              onPressed: () async {
                if (_page == _slides.length - 1) {
                  await ref.read(appSettingsProvider.notifier).completeOnboarding();
                  if (context.mounted) {
                    context.go(HomeScreen.routePath);
                  }
                  return;
                }
                await _controller.nextPage(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
