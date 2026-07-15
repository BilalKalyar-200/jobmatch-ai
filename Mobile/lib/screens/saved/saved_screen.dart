import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/skeleton_loader.dart';

import '../../core/api/api_client.dart';
import '../../core/data/countries.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/job_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Saved and history',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const TabBar(
              tabs: [
                Tab(text: 'Saved jobs'),
                Tab(text: 'Recent searches'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [_SavedJobsTab(), _SearchHistoryTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedJobsTab extends ConsumerWidget {
  const _SavedJobsTab();

  Future<void> _unsave(
    WidgetRef ref,
    BuildContext context,
    String jobId,
  ) async {
    try {
      await ref.read(savedRepositoryProvider).unsaveJob(jobId);
      ref.invalidate(savedJobsProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              readableErrorMessage(
                error,
                fallback: 'Could not remove saved job.',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedJobsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(savedJobsProvider);
        try {
          await ref.read(savedJobsProvider.future);
        } catch (_) {
          // The error is already reflected below via AsyncValue.when.
        }
      },
      child: savedAsync.when(
        data: (saved) {
          if (saved.savedJobs.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: const [
                EmptyState(
                  icon: Icons.bookmark_border,
                  title: 'No saved jobs yet',
                  description:
                      'Save jobs from the detail screen to review them here later.',
                ),
              ],
            );
          }
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: saved.savedJobs.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: JobCard(
                  job: item.job,
                  onTap: () =>
                      context.push('/jobs/${item.job.jobId}', extra: item.job),
                  trailing: IconButton(
                    tooltip: 'Remove saved job',
                    onPressed: () => _unsave(ref, context, item.job.jobId),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: const JobListSkeleton(),
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            ErrorBanner(
              message: readableErrorMessage(
                error,
                fallback: 'Could not load saved jobs.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHistoryTab extends ConsumerWidget {
  const _SearchHistoryTab();

  Future<void> _deleteSearch(
    WidgetRef ref,
    BuildContext context,
    String searchId,
  ) async {
    try {
      await ref.read(savedRepositoryProvider).deleteSearchHistory(searchId);
      ref.invalidate(searchHistoryProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              readableErrorMessage(
                error,
                fallback: 'Could not delete search history entry.',
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(searchHistoryProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(searchHistoryProvider);
        try {
          await ref.read(searchHistoryProvider.future);
        } catch (_) {
          // The error is already reflected below via AsyncValue.when.
        }
      },
      child: historyAsync.when(
        data: (history) {
          if (history.searches.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: const [
                EmptyState(
                  icon: Icons.history,
                  title: 'No search history yet',
                  description: 'Your recent job searches will show up here.',
                ),
              ],
            );
          }
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: history.searches.map((search) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              search.niche,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${search.cities.join(', ')}, ${getCountryName(search.country)}',
                            ),
                            Text(
                              DateFormat.yMMMd().add_jm().format(
                                search.createdAt.toLocal(),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete search',
                        onPressed: () => _deleteSearch(ref, context, search.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: const JobListSkeleton(itemCount: 3),
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            ErrorBanner(
              message: readableErrorMessage(
                error,
                fallback: 'Could not load search history.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final savedJobsProvider = FutureProvider((ref) async {
  return ref.watch(savedRepositoryProvider).listSavedJobs();
});

final searchHistoryProvider = FutureProvider((ref) async {
  return ref.watch(savedRepositoryProvider).listSearchHistory();
});
