import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/skeleton_loader.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../models/job_models.dart';
import '../../models/resume_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/resume_preview_text.dart';
import '../../widgets/score_ring.dart';

class ResumeScreen extends ConsumerStatefulWidget {
  const ResumeScreen({super.key, this.matchResult, this.jobTitle});

  final JobMatchResponse? matchResult;
  final String? jobTitle;

  @override
  ConsumerState<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends ConsumerState<ResumeScreen> {
  ResumeResponse? _resume;
  JobMatchResponse? _matchResult;
  String? _jobTitle;
  bool _loading = true;
  bool _uploading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _matchResult = widget.matchResult;
    _jobTitle = widget.jobTitle;
    _loadResume();
  }

  @override
  void didUpdateWidget(covariant ResumeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matchResult != null) {
      _matchResult = widget.matchResult;
      _jobTitle = widget.jobTitle;
    }
  }

  Future<void> _loadResume() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resume = await ref.read(resumeRepositoryProvider).getMyResume();
      if (mounted) setState(() => _resume = resume);
    } catch (error) {
      if (mounted) setState(() => _resume = null);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
      withData: false,
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.single.path == null) {
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
      _success = null;
      _matchResult = null;
    });

    try {
      final file = File(result.files.single.path!);
      final response = await ref
          .read(resumeRepositoryProvider)
          .uploadResume(file);
      setState(() {
        _resume = response.resume;
        _success = response.message;
      });
    } catch (error) {
      setState(
        () => _error = readableErrorMessage(error, fallback: 'Upload failed.'),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  Future<void> _scoreWithPreview() async {
    final preview = _resume?.textPreview;
    if (preview == null || preview.isEmpty) {
      return;
    }

    setState(() {
      _error = null;
    });

    try {
      final result = await ref
          .read(jobsRepositoryProvider)
          .matchJob(jobDescription: preview);
      setState(() => _matchResult = result);
    } catch (error) {
      setState(
        () => _error = readableErrorMessage(error, fallback: 'Scoring failed.'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Resume upload and scoring',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload a PDF or DOCX resume, then score it against a job from the job detail screen.',
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _uploading ? null : _pickAndUpload,
            icon: const Icon(Icons.upload_file),
            label: _uploading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Pick resume file'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            ErrorBanner(message: _error!),
          ],
          if (_success != null) ...[
            const SizedBox(height: 12),
            SuccessBanner(message: _success!),
          ],
          const SizedBox(height: 20),
          if (_loading)
            const ResumeCardSkeleton()
          else if (_resume == null)
            const AppCard(child: Text('No resume uploaded yet.'))
          else ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current resume',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(_resume!.filename),
                  const SizedBox(height: 12),
                  ResumePreviewText(text: _resume!.textPreview),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_matchResult == null)
              OutlinedButton(
                onPressed: _scoreWithPreview,
                child: const Text('Score using resume preview text'),
              ),
          ],
          if (_jobTitle != null) ...[
            const SizedBox(height: 12),
            Text('Latest score request for: $_jobTitle'),
          ],
          if (_matchResult != null) ...[
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                children: [
                  ScoreRing(score: _matchResult!.finalScore),
                  const SizedBox(height: 16),
                  Text(
                    _matchResult!.scoringFormula,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ScoreTile(
                          label: 'Keyword score',
                          value: _matchResult!.keywordScore,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ScoreTile(
                          label: 'Semantic score',
                          value: _matchResult!.semanticScore,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _KeywordSection(
              title: 'Matched keywords',
              color: AppColors.green50,
              border: AppColors.green200,
              textColor: AppColors.green800,
              keywords: _matchResult!.matchedKeywords,
              emptyText: 'No matched keywords yet.',
            ),
            const SizedBox(height: 12),
            _KeywordSection(
              title: 'Missing keywords',
              color: AppColors.amber50,
              border: AppColors.amber200,
              textColor: AppColors.amber800,
              keywords: _matchResult!.missingKeywords,
              emptyText: 'No missing keywords.',
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            '${value.round()}%',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _KeywordSection extends StatelessWidget {
  const _KeywordSection({
    required this.title,
    required this.color,
    required this.border,
    required this.textColor,
    required this.keywords,
    required this.emptyText,
  });

  final String title;
  final Color color;
  final Color border;
  final Color textColor;
  final List<String> keywords;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
          ),
          const SizedBox(height: 10),
          if (keywords.isEmpty)
            Text(emptyText, style: TextStyle(color: textColor))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: keywords
                  .map((keyword) => Chip(label: Text(keyword)))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
