import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/resume_preview_formatter.dart';
import 'app_card.dart';

class ResumePreviewText extends StatelessWidget {
  const ResumePreviewText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.accent : AppColors.brand600;

    final bodyStyle =
        theme.textTheme.bodyMedium?.copyWith(height: 1.7) ??
        const TextStyle(height: 1.7);
    final nameStyle =
        theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          height: 1.4,
        ) ??
        bodyStyle.copyWith(fontWeight: FontWeight.bold);
    final subtitleStyle =
        theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
          height: 1.5,
        ) ??
        bodyStyle;
    final contactStyle = bodyStyle.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      fontSize: (bodyStyle.fontSize ?? 14) - 1,
    );
    final headerStyle = bodyStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: accent,
      fontSize: (bodyStyle.fontSize ?? 14) + 1,
    );

    final spans = ResumePreviewFormatter.buildDisplaySpans(
      text,
      bodyStyle: bodyStyle,
      nameStyle: nameStyle,
      subtitleStyle: subtitleStyle,
      contactStyle: contactStyle,
      headerStyle: headerStyle,
    );

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SelectableText.rich(TextSpan(children: spans)),
      ),
    );
  }
}
