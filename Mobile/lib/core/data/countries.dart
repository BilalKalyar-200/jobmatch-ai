class CountryOption {
  const CountryOption({required this.name, required this.code});

  final String name;
  final String code;
}

/// Static ISO country list. UI shows names, API receives codes only.
final List<CountryOption> countries = [
  const CountryOption(name: 'United States', code: 'us'),
  const CountryOption(name: 'United Kingdom', code: 'gb'),
  const CountryOption(name: 'Canada', code: 'ca'),
  const CountryOption(name: 'Australia', code: 'au'),
  const CountryOption(name: 'Germany', code: 'de'),
  const CountryOption(name: 'France', code: 'fr'),
  const CountryOption(name: 'Netherlands', code: 'nl'),
  const CountryOption(name: 'Sweden', code: 'se'),
  const CountryOption(name: 'Norway', code: 'no'),
  const CountryOption(name: 'Denmark', code: 'dk'),
  const CountryOption(name: 'Finland', code: 'fi'),
  const CountryOption(name: 'Ireland', code: 'ie'),
  const CountryOption(name: 'Switzerland', code: 'ch'),
  const CountryOption(name: 'Austria', code: 'at'),
  const CountryOption(name: 'Belgium', code: 'be'),
  const CountryOption(name: 'Spain', code: 'es'),
  const CountryOption(name: 'Italy', code: 'it'),
  const CountryOption(name: 'Portugal', code: 'pt'),
  const CountryOption(name: 'Poland', code: 'pl'),
  const CountryOption(name: 'Czech Republic', code: 'cz'),
  const CountryOption(name: 'India', code: 'in'),
  const CountryOption(name: 'Pakistan', code: 'pk'),
  const CountryOption(name: 'Bangladesh', code: 'bd'),
  const CountryOption(name: 'United Arab Emirates', code: 'ae'),
  const CountryOption(name: 'Saudi Arabia', code: 'sa'),
  const CountryOption(name: 'Singapore', code: 'sg'),
  const CountryOption(name: 'Malaysia', code: 'my'),
  const CountryOption(name: 'Indonesia', code: 'id'),
  const CountryOption(name: 'Philippines', code: 'ph'),
  const CountryOption(name: 'Japan', code: 'jp'),
  const CountryOption(name: 'South Korea', code: 'kr'),
  const CountryOption(name: 'China', code: 'cn'),
  const CountryOption(name: 'Hong Kong', code: 'hk'),
  const CountryOption(name: 'New Zealand', code: 'nz'),
  const CountryOption(name: 'South Africa', code: 'za'),
  const CountryOption(name: 'Nigeria', code: 'ng'),
  const CountryOption(name: 'Kenya', code: 'ke'),
  const CountryOption(name: 'Egypt', code: 'eg'),
  const CountryOption(name: 'Brazil', code: 'br'),
  const CountryOption(name: 'Mexico', code: 'mx'),
  const CountryOption(name: 'Argentina', code: 'ar'),
  const CountryOption(name: 'Colombia', code: 'co'),
  const CountryOption(name: 'Chile', code: 'cl'),
  const CountryOption(name: 'Turkey', code: 'tr'),
  const CountryOption(name: 'Israel', code: 'il'),
  const CountryOption(name: 'Qatar', code: 'qa'),
  const CountryOption(name: 'Kuwait', code: 'kw'),
  const CountryOption(name: 'Romania', code: 'ro'),
  const CountryOption(name: 'Hungary', code: 'hu'),
  const CountryOption(name: 'Greece', code: 'gr'),
  const CountryOption(name: 'Ukraine', code: 'ua'),
]..sort((a, b) => a.name.compareTo(b.name));

String getCountryName(String code) {
  final normalized = code.toLowerCase();
  return countries.firstWhere((c) => c.code == normalized, orElse: () => CountryOption(name: code.toUpperCase(), code: normalized)).name;
}

String? countryCodeFromName(String? name) {
  if (name == null || name.isEmpty) {
    return null;
  }
  final normalized = name.toLowerCase();
  for (final country in countries) {
    if (country.code == normalized || country.name.toLowerCase() == normalized) {
      return country.code;
    }
  }
  return null;
}
