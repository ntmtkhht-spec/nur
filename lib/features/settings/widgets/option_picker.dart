import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// One choice in an [showOptionPicker] sheet.
typedef PickerOption<T> = ({T value, String label, String? subtitle});

/// Bottom sheet that lets the user pick one value out of [options].
///
/// Returns the chosen value, or null when dismissed. Scrollable, because the
/// calculation method list is long enough to run past the screen.
Future<T?> showOptionPicker<T>({
  required BuildContext context,
  required String title,
  required List<PickerOption<T>> options,
  required T current,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final colors = AppColors.of(context);

      return DraggableScrollableSheet(
        initialChildSize: options.length > 6 ? 0.7 : 0.45,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: colors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: options.length,
                    itemBuilder: (context, i) {
                      final option = options[i];
                      final selected = option.value == current;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(option.value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option.label,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: selected
                                              ? colors.darkGreen
                                              : colors.textDark,
                                        ),
                                      ),
                                      if (option.subtitle != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          option.subtitle!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check,
                                    size: 20,
                                    color: colors.darkGreen,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
