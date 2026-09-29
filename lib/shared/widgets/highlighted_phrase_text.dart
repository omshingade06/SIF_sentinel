import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../models/sif_analysis_model.dart';

class HighlightedPhraseText extends StatelessWidget {
  final String text;
  final List<EvidenceSpan> evidenceSpans;
  final TextStyle? baseStyle;

  const HighlightedPhraseText({
    super.key,
    required this.text,
    required this.evidenceSpans,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (evidenceSpans.isEmpty || text.isEmpty) {
      return Text(
        text,
        style: baseStyle ?? AppTypography.bodyMedium.copyWith(height: 1.6),
      );
    }

    // Build segments
    final spans = <InlineSpan>[];
    final defaultStyle = baseStyle ?? AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.6,
        );

    // Sort evidence spans by position
    final sortedSpans = <Map<String, dynamic>>[];
    final lowerText = text.toLowerCase();

    for (final evidence in evidenceSpans) {
      final phraseLower = evidence.phrase.toLowerCase().trim();
      if (phraseLower.isEmpty) continue;
      int startIdx = lowerText.indexOf(phraseLower);
      while (startIdx != -1) {
        final endIdx = startIdx + phraseLower.length;
        sortedSpans.add({
          'start': startIdx,
          'end': endIdx,
          'category': evidence.category,
          'phrase': evidence.phrase,
        });
        startIdx = lowerText.indexOf(phraseLower, endIdx);
      }
    }

    // Sort and remove overlaps
    sortedSpans.sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));
    final nonOverlapping = <Map<String, dynamic>>[];
    int lastEnd = 0;
    for (final s in sortedSpans) {
      final start = s['start'] as int;
      final end = s['end'] as int;
      if (start >= lastEnd) {
        nonOverlapping.add(s);
        lastEnd = end;
      }
    }

    int currentIdx = 0;
    for (final span in nonOverlapping) {
      final start = span['start'] as int;
      final end = span['end'] as int;
      final category = span['category'] as String;

      // Add preceding plain text
      if (start > currentIdx) {
        spans.add(TextSpan(
          text: text.substring(currentIdx, start),
          style: defaultStyle,
        ));
      }

      // Add highlighted span
      Color highlightBg;
      Color highlightText;
      FontWeight weight = FontWeight.w600;

      switch (category) {
        case 'barrier_failure':
          highlightBg = AppColors.criticalBg;
          highlightText = AppColors.critical;
          break;
        case 'hazard':
          highlightBg = AppColors.highBg;
          highlightText = const Color(0xFFC2410C);
          break;
        case 'exposure':
          highlightBg = AppColors.purpleBg;
          highlightText = AppColors.purple;
          break;
        default:
          highlightBg = AppColors.highlightYellowBg;
          highlightText = const Color(0xFF854D0E);
      }

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
            margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 1),
            decoration: BoxDecoration(
              color: highlightBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: highlightText.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Text(
              text.substring(start, end),
              style: defaultStyle.copyWith(
                color: highlightText,
                fontWeight: weight,
                fontSize: (defaultStyle.fontSize ?? 14) * 0.96,
              ),
            ),
          ),
        ),
      );

      currentIdx = end;
    }

    // Add remaining text
    if (currentIdx < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIdx),
        style: defaultStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
