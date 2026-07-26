import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../onboarding_state.dart';
import '../widgets/onboarding_scaffold.dart';
import '../widgets/ornament_divider.dart';

class NameScreen extends ConsumerStatefulWidget {
  final int stepIndex;
  final VoidCallback onNext;

  const NameScreen({
    super.key,
    required this.stepIndex,
    required this.onNext,
  });

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(onboardingProvider).name,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _controller.text.trim().isNotEmpty;

    return OnboardingScaffold(
      currentStep: widget.stepIndex,
      buttonEnabled: canContinue,
      onNext: () {
        ref.read(onboardingProvider.notifier).setName(_controller.text.trim());
        widget.onNext();
      },
      children: [
        const SizedBox(height: 16),
        _NameHeroIcon(),
        const SizedBox(height: 32),
        const Text(
          'Wie dürfen wir dich nennen?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Für deine persönliche Begrüßung.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        const OrnamentDivider(),
        const SizedBox(height: 28),
        TextField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (canContinue) {
              ref.read(onboardingProvider.notifier).setName(_controller.text.trim());
              widget.onNext();
            }
          },
          style: const TextStyle(fontSize: 18, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Dein Name',
            suffixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
            filled: true,
            fillColor: AppColors.cardBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'z. B. für „Assalamu alaikum, ${_controller.text.trim().isEmpty ? 'Dein Name' : _controller.text.trim()}"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _NameHeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            top: 24,
            child: Icon(Icons.dark_mode_outlined, size: 20, color: AppColors.accentGold),
          ),
          const Icon(Icons.person, size: 56, color: AppColors.darkGreen),
          Positioned(
            bottom: 18,
            left: 18,
            child: Icon(Icons.mosque_outlined,
                size: 22, color: AppColors.accentGold.withValues(alpha: 0.6)),
          ),
          Positioned(
            bottom: 18,
            right: 18,
            child: Icon(Icons.mosque_outlined,
                size: 22, color: AppColors.accentGold.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
