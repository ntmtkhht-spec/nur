import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'providers/tasbih_provider.dart';

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbihProvider);
    final notifier = ref.read(tasbihProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const SizedBox(width: 48), // Spacer to balance reset button
                  const Spacer(),
                  const Text(
                    'Tasbih',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      notifier.reset();
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.darkGreen,
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dropdown Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _showDhikrSelector(context, state.selectedDhikr, notifier),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.darkGreen, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.ads_click_rounded, color: AppColors.darkGreen, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${state.selectedDhikr.text}  •  ${state.selectedDhikr.arabic}',
                          style: const TextStyle(
                            color: AppColors.darkGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.darkGreen),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Huge Touch Area
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (state.count + 1 == state.selectedDhikr.target) {
                  HapticFeedback.mediumImpact(); // feedback when hitting target
                }
                notifier.increment();
              },
              child: _CircularCounter(
                count: state.count,
                target: state.selectedDhikr.target,
              ),
            ),

            const SizedBox(height: 32),

            // Round info
            Text(
              '/ ${state.selectedDhikr.target}',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              '${state.round}. Runde',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Round indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(10, (index) {
                final isActive = (index + 1) == state.round;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.darkGreen : Colors.transparent,
                    border: Border.all(
                      color: isActive ? AppColors.darkGreen : AppColors.accentGold,
                      width: 1,
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),
            
            // Hint
            Column(
              children: [
                const Icon(Icons.touch_app_outlined, size: 32, color: AppColors.textMuted),
                const SizedBox(height: 8),
                Text(
                  'Tippe zum Zählen',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  void _showDhikrSelector(BuildContext context, Dhikr currentDhikr, TasbihNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: defaultDhikrs.map((dhikr) {
            final isSelected = dhikr == currentDhikr;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              leading: Icon(
                Icons.ads_click_rounded,
                color: isSelected ? AppColors.accentGold : AppColors.darkGreen,
              ),
              title: Text(
                '${dhikr.text}  •  ${dhikr.arabic}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.accentGold : AppColors.darkGreen,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check, color: AppColors.accentGold) : null,
              onTap: () {
                notifier.setDhikr(dhikr);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CircularCounter extends StatelessWidget {
  final int count;
  final int target;

  const _CircularCounter({
    required this.count,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen.withValues(alpha: 0.05),
            ),
          ),
          
          // Custom Paint for progress arc
          SizedBox(
            width: 280,
            height: 280,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: target > 0 ? (count / target).clamp(0.0, 1.0) : 0,
              ),
              duration: const Duration(milliseconds: 200),
              builder: (context, progress, _) {
                return CustomPaint(
                  painter: _TasbihArcPainter(progress: progress),
                );
              },
            ),
          ),
          
          // Main dark green circle
          Container(
            width: 240,
            height: 240,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkGreen,
            ),
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 84,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasbihArcPainter extends CustomPainter {
  final double progress;

  _TasbihArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4; // Padding
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    // Background arc (empty)
    final bgPaint = Paint()
      ..color = AppColors.goldLight.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(rect, -pi / 2, 2 * pi, false, bgPaint);

    // Foreground arc
    final fgPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
      
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, fgPaint);
    
    // Golden Knob at the end of the arc
    final knobAngle = -pi / 2 + sweepAngle;
    final knobX = center.dx + radius * cos(knobAngle);
    final knobY = center.dy + radius * sin(knobAngle);
    
    final knobPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(knobX, knobY), 8, knobPaint);
  }

  @override
  bool shouldRepaint(covariant _TasbihArcPainter old) => old.progress != progress;
}
