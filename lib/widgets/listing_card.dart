import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../theme.dart';
import '../models/scrap_listing.dart';

class ListingCard extends StatelessWidget {
  final ScrapListing listing;
  final bool compact;

  const ListingCard({super.key, required this.listing, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/listings/${listing.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo + badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: listing.photoUrls.isNotEmpty
                      ? Image.network(
                          listing.photoUrls.first,
                          height: compact ? 120 : 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _PhotoPlaceholder(height: compact ? 120 : 180),
                        )
                      : _PhotoPlaceholder(height: compact ? 120 : 180),
                ),
                // Urgent badge
                if (listing.isUrgent)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.rust,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                // Photo count
                if (listing.photoUrls.length > 1)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_library_outlined, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '${listing.photoUrls.length}',
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Metal type chip
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${listing.metalType.emoji} ${listing.metalType.displayName}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Price row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${listing.pricePerKg.toStringAsFixed(0)} CFA/kg',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${listing.weightKg.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Location + time
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.locationName,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeago.format(listing.createdAt, locale: 'fr'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    // Seller row
                    Row(
                      children: [
                        _SellerAvatar(name: listing.sellerName, rating: listing.sellerRating),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.sellerName,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  )),
                              Row(
                                children: [
                                  const Icon(Icons.star, size: 12, color: AppTheme.accent),
                                  const SizedBox(width: 3),
                                  Text(listing.sellerRating.toStringAsFixed(1),
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // View count
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye_outlined, size: 13, color: AppTheme.textHint),
                            const SizedBox(width: 3),
                            Text('${listing.viewCount}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Voice note indicator
                        if (listing.voiceNoteUrl != null)
                          const Icon(Icons.mic, size: 16, color: AppTheme.primary),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final double height;
  const _PhotoPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppTheme.surface,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 40, color: AppTheme.textHint),
          SizedBox(height: 8),
          Text('Pas de photo', style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SellerAvatar extends StatelessWidget {
  final String name;
  final double rating;
  const _SellerAvatar({required this.name, required this.rating});

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
