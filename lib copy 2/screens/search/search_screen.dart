import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/listing_service.dart';
import '../../widgets/listing_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  final List<String> _recent = ['Cuivre câbles', 'Aluminium marmites', 'Ferraille voiture'];
  final List<String> _popular = ['Cuivre', 'Aluminium', 'Acier', 'Laiton', 'Fer', 'Zinc'];

  @override
  Widget build(BuildContext context) {
    final service = context.read<ListingService>();
    final results = _query.isEmpty ? [] : service.filterListings(query: _query);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Rechercher des métaux...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () { _ctrl.clear(); setState(() => _query = ''); },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _buildSuggestions()
          : results.isEmpty
              ? _buildNoResults()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListingCard(listing: results[i]),
                  ),
                ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recent.isNotEmpty) ...[
            Text('Recherches récentes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ..._recent.map((s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: AppTheme.textHint),
              title: Text(s),
              trailing: const Icon(Icons.north_west, size: 16, color: AppTheme.textHint),
              onTap: () => setState(() { _ctrl.text = s; _query = s; }),
            )),
            const Divider(height: 24),
          ],
          Text('Recherches populaires', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popular.map((s) => GestureDetector(
              onTap: () => setState(() { _ctrl.text = s; _query = s; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Text(s, style: Theme.of(context).textTheme.bodyMedium),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text('Aucun résultat pour "$_query"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          const Text('Essayez un autre terme'),
        ],
      ),
    );
  }
}
