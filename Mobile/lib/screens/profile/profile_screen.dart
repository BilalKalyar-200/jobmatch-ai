import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/countries.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authProvider).profile;
    final themeMode = ref.watch(themeModeProvider);

    if (profile == null) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final niche = profile.preferredNiches.isNotEmpty
        ? profile.preferredNiches.first
        : 'Not set';
    final countryCode = profile.preferredCountries.isNotEmpty
        ? profile.preferredCountries.first
        : '';
    final country = countryCode.isEmpty
        ? 'Not set'
        : getCountryName(countryCode);
    final cities = profile.preferredCities.isEmpty
        ? 'Not set'
        : profile.preferredCities.join(', ');

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(profile.email),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Toggle theme',
                onPressed: () =>
                    ref.read(themeModeProvider.notifier).toggleTheme(),
                icon: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name', style: Theme.of(context).textTheme.labelLarge),
                Text(profile.name),
                const SizedBox(height: 12),
                Text('Niche', style: Theme.of(context).textTheme.labelLarge),
                Text(niche),
                const SizedBox(height: 12),
                Text('Country', style: Theme.of(context).textTheme.labelLarge),
                Text(country),
                const SizedBox(height: 12),
                Text('Cities', style: Theme.of(context).textTheme.labelLarge),
                Text(cities),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/preferences'),
            child: const Text('Edit preferences'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
