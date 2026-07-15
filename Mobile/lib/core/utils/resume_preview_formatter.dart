import 'package:flutter/material.dart';

/// Display-only resume preview formatting. Never use for API requests.
class ResumePreviewFormatter {
  static const _sectionHeaders = [
    'Summary',
    'Professional Summary',
    'Objective',
    'Profile',
    'Experience',
    'Work Experience',
    'Professional Experience',
    'Employment History',
    'Education',
    'Skills',
    'Technical Skills',
    'Core Competencies',
    'Projects',
    'Certifications',
    'Licenses and Certifications',
    'Achievements',
    'Awards',
    'Languages',
    'Interests',
    'References',
  ];

  static String formatForDisplay(String text) {
    if (text.trim().isEmpty) {
      return text;
    }

    if (RegExp(r'[\r\n]').hasMatch(text)) {
      return text;
    }

    final headerPattern = RegExp(
      r'(\s)(' + _sectionHeaders.join('|') + r')(?=\s|:|$)',
      caseSensitive: false,
    );

    var formatted = text.replaceAllMapped(
      headerPattern,
      (match) => '\n\n${match.group(2)}',
    );
    formatted = formatted.replaceFirst(
      RegExp(
        r'^(' + _sectionHeaders.join('|') + r')(?=\s|:|$)',
        caseSensitive: false,
      ),
      '\n\n\$1',
    );

    return formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  /// Builds styled text spans for the resume preview: the first line is
  /// treated as the person's name, the next short line as a subtitle or
  /// role, lines with contact details get a muted style, section headers
  /// get a bold accent style, everything else uses the base body style.
  /// This is a display only transformation, never use it to alter data
  /// sent to the backend.
  static List<TextSpan> buildDisplaySpans(
    String rawText, {
    required TextStyle bodyStyle,
    required TextStyle nameStyle,
    required TextStyle subtitleStyle,
    required TextStyle contactStyle,
    required TextStyle headerStyle,
  }) {
    final formatted = formatForDisplay(rawText);
    if (formatted.trim().isEmpty) {
      return [TextSpan(text: formatted, style: bodyStyle)];
    }

    final lines = formatted.split('\n');
    final spans = <TextSpan>[];
    var seenName = false;
    var seenSubtitleOrContact = false;

    bool isSectionHeader(String line) {
      final cleaned = line.trim().replaceAll(RegExp(r':$'), '');
      return _sectionHeaders.any(
        (header) => header.toLowerCase() == cleaned.toLowerCase(),
      );
    }

    bool looksLikeContactLine(String line) {
      final lower = line.toLowerCase();
      return lower.contains('@') ||
          lower.contains('http') ||
          lower.contains('github.com') ||
          lower.contains('linkedin.com') ||
          RegExp(r'\+?\d[\d\s-]{7,}').hasMatch(line);
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isLast = i == lines.length - 1;
      final suffix = isLast ? '' : '\n';

      if (line.trim().isEmpty) {
        spans.add(TextSpan(text: '$line$suffix', style: bodyStyle));
        continue;
      }

      if (!seenName) {
        spans.add(TextSpan(text: '$line$suffix', style: nameStyle));
        seenName = true;
        continue;
      }

      if (!seenSubtitleOrContact &&
          !isSectionHeader(line) &&
          line.trim().length <= 90) {
        if (looksLikeContactLine(line)) {
          spans.add(TextSpan(text: '$line$suffix', style: contactStyle));
        } else {
          spans.add(TextSpan(text: '$line$suffix', style: subtitleStyle));
        }
        seenSubtitleOrContact = true;
        continue;
      }

      if (isSectionHeader(line)) {
        spans.add(TextSpan(text: '$line$suffix', style: headerStyle));
        continue;
      }

      if (looksLikeContactLine(line)) {
        spans.add(TextSpan(text: '$line$suffix', style: contactStyle));
        continue;
      }

      spans.add(TextSpan(text: '$line$suffix', style: bodyStyle));
    }

    return spans;
  }
}
