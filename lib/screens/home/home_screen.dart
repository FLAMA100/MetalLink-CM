import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../services/auth_service.dart';
import '../../services/listing_service.dart';
import '../../services/location_service.dart';
import '../../models/scrap_listing.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/metal_type_chip.dart';
import '../../widgets/stats_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MetalType? _selectedMetal;

  @override
  void initState() {
    super.initState();
    // Request location on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationService>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final listings = context.watch<ListingService>();
    final location = context.watch<LocationService>();
    final user = auth.currentUser;

    final filtered = listings.filterListings(metalType: _selectedMetal);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppTheme.cardBg,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.cardBg,
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bonjour, ${user?.fullName.split(' ').first ?? 'Utilisateur'} 👋',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: AppTheme.rust),
                                  const SizedBox(width: 4),
                                  Text(
                                    location.locationName,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Notifications
                        GestureDetector(
                          onTap: () => context.go('/notifications'),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: const Icon(Icons.notifications_outlined, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  GestureDetector(
                    onTap: () => context.go('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppTheme.textHint, size: 20),
                          const SizedBox(width: 10),
                          Text('Rechercher fer, cuivre, aluminium...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textHint,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats banner
                  const StatsBanner(),
                  const SizedBox(height: 24),

                  // Quick actions
                  Text('Actions rapides',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _QuickAction(
                        icon: Icons.add_a_photo_outlined,
                        label: 'Vendre ferraille',
                        color: AppTheme.primary,
                        onTap: () => context.go('/create-listing'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.search,
                        label: 'Trouver métaux',
                        color: AppTheme.rust,
                        onTap: () => context.go('/listings'),
                      ),
                      const SizedBox(width: 12),
                      _QuickAction(
                        icon: Icons.people_outline,
                        label: 'Mes contacts',
                        color: const Color(0xFF1A4A6B),
                        onTap: () => context.go('/messages'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Metal type filter
                  Text('Filtrer par métal',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Metal chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${filtered.length} annonce${filtered.length > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () => context.go('/listings'),
                    child: const Text('Voir tout'),
                  ),
                ],
              ),
            ),
          ),

          // Listings
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                if (i >= filtered.length) return const SizedBox(height: 100);
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: ListingCard(listing: filtered[i]),
                );
              },
              childCount: filtered.isEmpty ? 1 : filtered.length + 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
