import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/skeleton_loader.dart';

import '../../core/api/api_client.dart';
import '../../core/data/countries.dart';
import '../../core/theme/app_colors.dart';
import '../../models/job_models.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/job_card.dart';
import '../profile/profile_screen.dart';
import '../resume/resume_screen.dart';
import '../saved/saved_screen.dart';
import '../../widgets/gradient_button.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Jobs',
      location: '/jobs',
    ),
    (
      icon: Icons.bookmark_outline,
      activeIcon: Icons.bookmark,
      label: 'Saved',
      location: '/saved',
    ),
    (
      icon: Icons.description_outlined,
      activeIcon: Icons.description,
      label: 'Resume',
      location: '/resume',
    ),
    (
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      location: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final index = _locationToIndex(GoRouterState.of(context).uri.path);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 10,
          bottom: bottomInset > 0 ? bottomInset : 10,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceElevated,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.slate200,
            ),
          ),
          boxShadow: isDark
              ? const []
              : [
                  BoxShadow(
                    color: AppColors.slate900.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
        ),
        child: SizedBox(
          height: 70,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = i == index;
              final activeColor = isDark ? AppColors.slate900 : Colors.white;
              final inactiveColor = isDark
                  ? AppColors.slate400
                  : AppColors.slate500;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.go(tab.location),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? AppColors.primaryGradient(isDark)
                          : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? tab.activeIcon : tab.icon,
                          size: 22,
                          color: selected ? activeColor : inactiveColor,
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: selected ? activeColor : inactiveColor,
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  int _locationToIndex(String path) {
    if (path.startsWith('/saved')) return 1;
    if (path.startsWith('/resume')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }
}

class JobsTab extends ConsumerStatefulWidget {
  const JobsTab({super.key});

  @override
  ConsumerState<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<JobsTab> {
  JobSearchResponse? _results;
  bool _loading = false;
  bool _hasSearched = false;
  String? _error;

  Future<void> _runSearch() async {
    final profile = ref.read(authProvider).profile;
    final niche = profile != null && profile.preferredNiches.isNotEmpty
        ? profile.preferredNiches.first
        : '';
    final country = profile != null && profile.preferredCountries.isNotEmpty
        ? profile.preferredCountries.first
        : '';
    final cities = profile?.preferredCities ?? const <String>[];

    if (niche.isEmpty || country.isEmpty || cities.isEmpty) {
      setState(
        () => _error =
            'Add a niche, country, and at least one city in preferences.',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final response = await ref
          .read(jobsRepositoryProvider)
          .searchJobs(niche: niche, country: country, cities: cities);
      setState(() => _results = response);
    } catch (error) {
      setState(() {
        _error = readableErrorMessage(error, fallback: 'Job search failed.');
        _results = null;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authProvider).profile;
    final niche = profile != null && profile.preferredNiches.isNotEmpty
        ? profile.preferredNiches.first
        : '';
    final country = profile != null && profile.preferredCountries.isNotEmpty
        ? profile.preferredCountries.first
        : '';
    final cities = profile?.preferredCities ?? const <String>[];
    final needsPreferences = niche.isEmpty || country.isEmpty || cities.isEmpty;
    final showInitialEmpty = !_hasSearched && !_loading && !needsPreferences;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: needsPreferences ? () async {} : _runSearch,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Job search',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        needsPreferences
                            ? 'Set your preferences before searching.'
                            : 'Searching for $niche in ${cities.join(', ')}, ${getCountryName(country)}.',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit preferences',
                  onPressed: () => context.push('/preferences'),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_hasSearched && !needsPreferences)
              _SearchSummaryBar(
                summary: '$niche · ${cities.join(', ')}',
                loading: _loading,
                onSearch: _runSearch,
              ),
            if (_hasSearched && !needsPreferences) const SizedBox(height: 20),
            if (needsPreferences) ...[
              const InfoBanner(
                message:
                    'Add a niche, country, and at least one city on the preferences page.',
              ),
              const SizedBox(height: 12),
            ],
            if (_error != null) ...[
              ErrorBanner(message: _error!),
              const SizedBox(height: 12),
            ],
            if (_loading) const JobListSkeleton(),
            if (showInitialEmpty)
              EmptyState(
                icon: Icons.travel_explore_outlined,
                title: 'Ready to find your next role',
                description:
                    'Your preferences are set. Run a search to see live job postings matched to your niche and cities.',
                action: GradientButton(
                  label: 'Search jobs now',
                  onPressed: _runSearch,
                ),
              ),
            if (!_loading && _hasSearched && (_results?.total ?? 0) == 0)
              EmptyState(
                icon: Icons.search_off_outlined,
                title: 'No jobs found',
                description:
                    'Try different cities or broaden your niche on the preferences page.',
                action: ElevatedButton(
                  onPressed: () => context.push('/preferences'),
                  child: const Text('Update preferences'),
                ),
              ),
            if (!_loading && (_results?.total ?? 0) > 0) ...[
              Text(
                'Found ${_results!.total} jobs${_results!.cached ? ' (cached results)' : ''}.',
              ),
              const SizedBox(height: 12),
              ..._results!.jobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCard(
                    job: job,
                    onTap: () => context.push('/jobs/${job.jobId}', extra: job),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchSummaryBar extends StatelessWidget {
  const _SearchSummaryBar({
    required this.summary,
    required this.loading,
    required this.onSearch,
  });

  final String summary;
  final bool loading;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: loading ? null : onSearch,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

typedef SavedTab = SavedScreen;
typedef ResumeTab = ResumeScreen;
typedef ProfileTab = ProfileScreen;
