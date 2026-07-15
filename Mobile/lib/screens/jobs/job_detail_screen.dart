import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../models/job_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_banner.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  const JobDetailScreen({
    super.key,
    required this.jobId,
    this.initialJob,
  });

  final String jobId;
  final JobPosting? initialJob;

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  late JobPosting? _job;
  bool _isSaved = false;
  bool _loadingSaved = false;
  bool _loadingMatch = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _job = widget.initialJob;
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    try {
      final saved = await ref.read(savedRepositoryProvider).listSavedJobs();
      setState(() {
        _isSaved = saved.savedJobs.any((item) => item.externalJobId == widget.jobId);
      });
    } catch (_) {
      // Non blocking if saved list fails.
    }
  }

  Future<void> _toggleSaved() async {
    final job = _job;
    if (job == null) {
      return;
    }

    setState(() {
      _loadingSaved = true;
      _error = null;
    });

    try {
      if (_isSaved) {
        await ref.read(savedRepositoryProvider).unsaveJob(job.jobId);
        setState(() => _isSaved = false);
      } else {
        await ref.read(savedRepositoryProvider).saveJob(job);
        setState(() => _isSaved = true);
      }
    } catch (error) {
      setState(() => _error = readableErrorMessage(error, fallback: 'Could not update saved job.'));
    } finally {
      if (mounted) {
        setState(() => _loadingSaved = false);
      }
    }
  }

  Future<void> _scoreResume() async {
    setState(() {
      _loadingMatch = true;
      _error = null;
    });

    try {
      final result = await ref.read(jobsRepositoryProvider).matchJob(jobId: widget.jobId);
      if (mounted) {
        context.go('/resume', extra: result);
      }
    } catch (error) {
      setState(() => _error = readableErrorMessage(error, fallback: 'Could not score resume.'));
    } finally {
      if (mounted) {
        setState(() => _loadingMatch = false);
      }
    }
  }

  Future<void> _openApplyLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: job == null
          ? const Center(child: Text('Job not found.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(job.companyName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(job.location)),
                          Chip(label: Text(job.sourcePlatform)),
                          Chip(label: Text(_formatPostedDate(job.postedDate))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: _loadingSaved ? null : _toggleSaved,
                            child: Text(_isSaved ? 'Unsave job' : 'Save job'),
                          ),
                          ElevatedButton(
                            onPressed: _loadingMatch ? null : _scoreResume,
                            child: _loadingMatch
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Score my resume'),
                          ),
                          if (job.applyLink.isNotEmpty)
                            ElevatedButton(
                              onPressed: () => _openApplyLink(job.applyLink),
                              child: const Text('Apply now'),
                            ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        ErrorBanner(message: _error!),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        job.description.isEmpty ? 'No description available.' : job.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatPostedDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Unknown';
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    return DateFormat.yMMMd().add_jm().format(parsed.toLocal());
  }
}
