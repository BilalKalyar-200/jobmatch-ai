import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A simple, dependency free shimmer effect. Wraps [child] with a moving
/// gradient highlight to indicate loading content.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.accent.withValues(alpha: 0.05)
        : AppColors.brand600.withValues(alpha: 0.04);
    final highlightColor = isDark
        ? AppColors.accent.withValues(alpha: 0.22)
        : AppColors.brand600.withValues(alpha: 0.14);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final dx = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1 + dx, 0),
              end: Alignment(0 + dx, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// A rounded rectangle placeholder block used to build skeleton layouts.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : AppColors.slate200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

Decoration _skeletonCardDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark ? AppColors.cardDark : AppColors.surfaceElevated,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: isDark ? AppColors.borderDark : AppColors.slate200,
    ),
  );
}

/// A skeleton placeholder shaped like a JobCard, shown while job results
/// or saved jobs are loading, instead of a blank screen with a spinner.
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _skeletonCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(width: 220, height: 16),
          SizedBox(height: 10),
          SkeletonBox(width: 140, height: 14),
          SizedBox(height: 14),
          Row(
            children: [
              SkeletonBox(width: 80, height: 24, borderRadius: 999),
              SizedBox(width: 8),
              SkeletonBox(width: 70, height: 24, borderRadius: 999),
              SizedBox(width: 8),
              SkeletonBox(width: 90, height: 24, borderRadius: 999),
            ],
          ),
        ],
      ),
    );
  }
}

/// A shimmering list of [JobCardSkeleton] placeholders, used as a loading
/// state for any screen that displays a list of job style cards.
class JobListSkeleton extends StatelessWidget {
  const JobListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(itemCount, (_) => const JobCardSkeleton()),
      ),
    );
  }
}

/// A skeleton placeholder shaped like the resume summary card, shown
/// while the current resume is loading instead of a spinner.
class ResumeCardSkeleton extends StatelessWidget {
  const ResumeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _skeletonCardDecoration(context),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 160, height: 16),
            SizedBox(height: 14),
            SkeletonBox(width: 200, height: 14),
            SizedBox(height: 20),
            SkeletonBox(width: double.infinity, height: 12),
            SizedBox(height: 8),
            SkeletonBox(width: double.infinity, height: 12),
            SizedBox(height: 8),
            SkeletonBox(width: 240, height: 12),
          ],
        ),
      ),
    );
  }
}
