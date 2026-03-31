import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../models/scrap_listing.dart';
import '../../services/listing_service.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/metal_type_chip.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  MetalType? _selectedMetal;
  String _selectedCity = '';
  String _query = '';
  bool _showFilters = false;

  final List<String> _cities = [
    '', 'Yaoundé', 'Douala', 'Bafoussam', 'Bamenda',
    'Garoua', 'Maroua', 'Ngaoundéré',
  ];

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ListingService>();
    final listings = service.filterListings(
      metalType: _selectedMetal,
      city: _selectedCity.isEmpty ? null : _selectedCity,
      query: _query.isEmpty ? null : _query,
    );

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Annonces'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilters ? AppTheme.primary : AppTheme.textPrimary,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Metal filter chips
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                MetalTypeChip(
                  label: 'Tous',
                  selected: _selectedMetal == null,
                  onTap: () => setState(() => _selectedMetal = null),
                ),
                ...MetalType.values.map((t) => MetalTypeChip(
                  label: t.displayName,
                  emoji: t.emoji,
                  selected: _selectedMetal == t,
                  onTap: () => setState(() => _selectedMetal = t),
                )),
              ],
            ),
          ),

          // City filter (expandable)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: _showFilters ? 56 : 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const Icon(Icons.location_city_outlined, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        isDense: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _cities.map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.isEmpty ? 'Toutes les villes' : c),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedCity = v ?? ''),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Text(
                  '${listings.length} résultat${listings.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: listings.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: listings.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListingCard(listing: listings[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text('Aucune annonce trouvée',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('Essayez d\'autres filtres',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
