import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/data/countries.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/city_multi_select.dart';
import '../../widgets/error_banner.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final _nicheController = TextEditingController();
  String _countryCode = '';
  List<String> _cities = [];
  String? _clearedNote;
  bool _loading = false;
  String? _error;
  String? _success;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final profile = ref.read(authProvider).profile;
    if (profile != null) {
      _nicheController.text = profile.preferredNiches.isNotEmpty
          ? profile.preferredNiches.first
          : '';
      _countryCode = profile.preferredCountries.isNotEmpty
          ? profile.preferredCountries.first.toLowerCase()
          : '';
      _cities = List<String>.from(profile.preferredCities);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nicheController.dispose();
    super.dispose();
  }

  void _onCountryChanged(String? code) {
    if (code == null) {
      return;
    }
    if (_countryCode.isNotEmpty && code != _countryCode && _cities.isNotEmpty) {
      setState(() {
        _cities = [];
        _clearedNote = 'Cities were cleared because you changed the country.';
      });
    } else {
      setState(() => _clearedNote = null);
    }
    setState(() => _countryCode = code);
  }

  Future<void> _save() async {
    final niche = _nicheController.text.trim();
    if (niche.isEmpty || _countryCode.isEmpty || _cities.isEmpty) {
      setState(() => _error = 'Add a niche, country, and at least one city.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      await ref
          .read(userRepositoryProvider)
          .updateProfile(
            preferredNiches: [niche],
            preferredCountries: [_countryCode],
            preferredCities: _cities,
          );
      await ref.read(authProvider.notifier).refreshProfile();
      if (mounted) {
        setState(() => _success = 'Preferences saved.');
        context.go('/jobs');
      }
    } catch (error) {
      setState(
        () => _error = readableErrorMessage(
          error,
          fallback: 'Could not save preferences.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _nicheController,
              decoration: const InputDecoration(
                labelText: 'Niche or role',
                hintText: 'Web Developer, Python Developer',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _countryCode.isEmpty ? null : _countryCode,
              decoration: const InputDecoration(labelText: 'Country'),
              items: countries
                  .map(
                    (country) => DropdownMenuItem(
                      value: country.code,
                      child: Text(country.name),
                    ),
                  )
                  .toList(),
              onChanged: _onCountryChanged,
            ),
            const SizedBox(height: 16),
            CityMultiSelect(
              countryCode: _countryCode,
              selectedCities: _cities,
              clearedNote: _clearedNote,
              onChanged: (cities) => setState(() => _cities = cities),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              ErrorBanner(message: _error!),
            ],
            if (_success != null) ...[
              const SizedBox(height: 16),
              SuccessBanner(message: _success!),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
