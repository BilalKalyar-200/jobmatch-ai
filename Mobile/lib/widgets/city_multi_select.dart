import 'package:flutter/material.dart';

import '../core/data/cities.dart';
import '../core/theme/app_colors.dart';
import 'app_card.dart';

class CityMultiSelect extends StatefulWidget {
  const CityMultiSelect({
    super.key,
    required this.countryCode,
    required this.selectedCities,
    required this.onChanged,
    this.clearedNote,
  });

  final String countryCode;
  final List<String> selectedCities;
  final ValueChanged<List<String>> onChanged;
  final String? clearedNote;

  @override
  State<CityMultiSelect> createState() => _CityMultiSelectState();
}

class _CityMultiSelectState extends State<CityMultiSelect> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<String> get _filteredCities {
    final available = getCitiesForCountry(widget.countryCode);
    final query = _searchController.text.trim().toLowerCase();
    return available.where((city) {
      final alreadySelected = widget.selectedCities.any(
        (selected) => selected.toLowerCase() == city.toLowerCase(),
      );
      if (alreadySelected) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return city.toLowerCase().contains(query);
    }).toList();
  }

  void _addCity(String city) {
    widget.onChanged([...widget.selectedCities, city]);
    _searchController.clear();
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasCountry = widget.countryCode.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cities', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TapRegion(
          onTapOutside: (_) {
            if (_showSuggestions) {
              setState(() => _showSuggestions = false);
              _focusNode.unfocus();
            }
          },
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.selectedCities.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.selectedCities.map((city) {
                      return Chip(
                        label: Text(city),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          widget.onChanged(
                            widget.selectedCities
                                .where((item) => item != city)
                                .toList(),
                          );
                        },
                      );
                    }).toList(),
                  ),
                if (!hasCountry)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Select a country first.'),
                  )
                else ...[
                  if (widget.selectedCities.isNotEmpty)
                    const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search and select a city',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onTap: () => setState(() => _showSuggestions = true),
                    onChanged: (_) => setState(() => _showSuggestions = true),
                    onSubmitted: (_) =>
                        setState(() => _showSuggestions = false),
                  ),
                  if (_showSuggestions)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: _filteredCities.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'No matching cities for this country.',
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredCities.length,
                              itemBuilder: (context, index) {
                                final city = _filteredCities[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(city),
                                  onTap: () => _addCity(city),
                                );
                              },
                            ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (widget.clearedNote != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.clearedNote!,
            style: const TextStyle(color: AppColors.amber800, fontSize: 12),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          'Select cities from the list for your chosen country. You can add multiple cities.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
