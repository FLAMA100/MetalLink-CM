import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../models/scrap_listing.dart';
import '../../services/listing_service.dart';
import '../../widgets/voice_note_player.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _photoIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingService>().incrementViewCount(widget.listingId);
    });
  }

  Future<void> _callSeller(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp(String phone) async {
    final number = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.read<ListingService>();
    final listing = service.getListingById(widget.listingId);

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Annonce introuvable')),
      );
    }

    final fmt = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Photo gallery app bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.black,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  if (listing.photoUrls.isNotEmpty)
                    PageView.builder(
                      itemCount: listing.photoUrls.length,
                      onPageChanged: (i) => setState(() => _photoIndex = i),
                      itemBuilder: (context, i) => Image.network(
                        listing.photoUrls[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.surface,
                          child: const Icon(Icons.broken_image_outlined, size: 60, color: AppTheme.textHint),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppTheme.surface,
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 80, color: AppTheme.textHint),
                      ),
                    ),
                  // Photo dots
                  if (listing.photoUrls.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0, right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(listing.photoUrls.length, (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _photoIndex ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _photoIndex ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        )),
                      ),
                    ),
                  // Urgent badge
                  if (listing.isUrgent)
                    Positioned(
                      top: 60, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.rust,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('URGENT',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metal type + title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.chipBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${listing.metalType.emoji} ${listing.metalType.displayName}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(listing.title, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 16),

                  // Price cards
                  Row(
                    children: [
                      _PriceCard(
                        label: 'Prix / kg',
                        value: '${fmt.format(listing.pricePerKg)} CFA',
                        color: AppTheme.primary,
                        icon: Icons.scale_outlined,
                      ),
                      const SizedBox(width: 12),
                      _PriceCard(
                        label: 'Poids total',
                        value: '${listing.weightKg.toStringAsFixed(1)} kg',
                        color: AppTheme.rust,
                        icon: Icons.inventory_outlined,
                      ),
                      const SizedBox(width: 12),
                      _PriceCard(
                        label: 'Total estimé',
                        value: '${fmt.format(listing.totalPrice.round())} CFA',
                        color: const Color(0xFF1A4A6B),
                        icon: Icons.payments_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price range hint
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppTheme.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Prix du marché : ${listing.metalType.priceRangeCFA}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.rust, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text('Description', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(listing.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
                  const SizedBox(height: 20),

                  // Voice note
                  if (listing.voiceNoteUrl != null) ...[
                    Text('Note vocale du vendeur', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    VoiceNotePlayer(audioUrl: listing.voiceNoteUrl!),
                    const SizedBox(height: 20),
                  ],

                  // Location
                  Text('Localisation', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.rust.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: AppTheme.rust, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.locationName,
                                  style: Theme.of(context).textTheme.titleMedium),
                              Text(listing.city,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: const Text('Voir carte'),
                          onPressed: () async {
                            final uri = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${listing.latitude},${listing.longitude}',
                            );
                            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seller info
                  Text('Vendeur', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Row(
                      children: [
                        _SellerAvatar(name: listing.sellerName),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.sellerName,
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppTheme.accent),
                                  const SizedBox(width: 4),
                                  Text('${listing.sellerRating.toStringAsFixed(1)} / 5',
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Stats
                        Column(
                          children: [
                            Text('${listing.viewCount}',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text('vues', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom contact bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            // WhatsApp
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text('WhatsApp'),
                onPressed: () => _whatsapp(listing.sellerPhone),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Call
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone, size: 18),
                label: const Text('Appeler'),
                onPressed: () => _callSeller(listing.sellerPhone),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Message in-app
            OutlinedButton(
              onPressed: () => context.go('/messages/${listing.sellerId}', extra: listing.sellerName),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              ),
              child: const Icon(Icons.message_outlined, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _PriceCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  final String name;
  const _SellerAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join();
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
      child: Center(
        child: Text(initials.toUpperCase(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primary)),
      ),
    );
  }
}
