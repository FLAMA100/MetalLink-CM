import 'package:flutter/foundation.dart';
import '../models/scrap_listing.dart';

class ListingService extends ChangeNotifier {
  List<ScrapListing> _listings = [];
  bool _isLoading = false;
  String? _error;

  List<ScrapListing> get listings => _listings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ScrapListing> get activeListings =>
      _listings.where((l) => l.status == ListingStatus.active).toList();

  ListingService() {
    _loadMockListings();
  }

  void _loadMockListings() {
    _listings = [
      ScrapListing(
        id: 'l001',
        sellerId: 'user_001',
        sellerName: 'Alphonse Nkemba',
        sellerPhone: '+237 6 70 12 34 56',
        sellerRating: 4.5,
        title: 'Gros lot de cuivre — câbles et tuyaux',
        description:
            'Collection de câbles électriques usagés et tuyaux en cuivre. Propre, sans plastique. Idéal pour fonderie.',
        metalType: MetalType.copper,
        weightKg: 45.0,
        pricePerKg: 1800,
        photoUrls: [
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600',
          'https://images.unsplash.com/photo-1581092334651-ddf19d571e09?w=600',
        ],
        latitude: 3.8667,
        longitude: 11.5167,
        locationName: 'Biyem-Assi, Yaoundé',
        city: 'Yaoundé',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        viewCount: 42,
        contactCount: 7,
        isUrgent: true,
      ),
      ScrapListing(
        id: 'l002',
        sellerId: 'user_002',
        sellerName: 'Marie-Claire Fouda',
        sellerPhone: '+237 6 55 98 76 54',
        sellerRating: 4.8,
        title: 'Ferraille variée — pièces de voiture',
        description:
            'Pièces métalliques diverses provenant de voitures hors d\'usage. Métal propre, pesé à l\'avance.',
        metalType: MetalType.iron,
        weightKg: 120.0,
        pricePerKg: 100,
        photoUrls: [
          'https://images.unsplash.com/photo-1566903451935-7e8835f3c45a?w=600',
        ],
        latitude: 4.0511,
        longitude: 9.7679,
        locationName: 'Akwa, Douala',
        city: 'Douala',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        viewCount: 89,
        contactCount: 15,
      ),
      ScrapListing(
        id: 'l003',
        sellerId: 'user_003',
        sellerName: 'Paul Essomba',
        sellerPhone: '+237 6 22 44 66 88',
        sellerRating: 3.9,
        title: 'Aluminium — casseroles et ustensiles',
        description:
            'Vieilles casseroles, marmites et ustensiles en aluminium. Bon pour refonte et fabrication de nouvelles marmites.',
        metalType: MetalType.aluminum,
        weightKg: 28.5,
        pricePerKg: 550,
        photoUrls: [
          'https://images.unsplash.com/photo-1585515320310-259814833e62?w=600',
        ],
        latitude: 3.8480,
        longitude: 11.5021,
        locationName: 'Mvan, Yaoundé',
        city: 'Yaoundé',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        viewCount: 31,
        contactCount: 4,
      ),
      ScrapListing(
        id: 'l004',
        sellerId: 'user_004',
        sellerName: 'Ibrahim Adamou',
        sellerPhone: '+237 6 77 33 22 11',
        sellerRating: 4.2,
        title: 'Laiton — robinets et raccords',
        description:
            'Robinets, valves et raccords en laiton récupérés. Très bon état, prix négociable pour grandes quantités.',
        metalType: MetalType.brass,
        weightKg: 15.0,
        pricePerKg: 1200,
        photoUrls: [
          'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?w=600',
        ],
        latitude: 10.5833,
        longitude: 14.8667,
        locationName: 'Centre, Garoua',
        city: 'Garoua',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        viewCount: 18,
        contactCount: 2,
        isUrgent: true,
      ),
      ScrapListing(
        id: 'l005',
        sellerId: 'user_005',
        sellerName: 'Christelle Bello',
        sellerPhone: '+237 6 88 11 55 99',
        sellerRating: 5.0,
        title: 'Acier inoxydable — équipements cuisine',
        description:
            'Équipements de restauration en acier inox hors service. Idéal pour fabricant d\'équipements. Très propre.',
        metalType: MetalType.steel,
        weightKg: 60.0,
        pricePerKg: 180,
        photoUrls: [
          'https://images.unsplash.com/photo-1556909114-44e3e70034e2?w=600',
        ],
        latitude: 4.0435,
        longitude: 9.6951,
        locationName: 'Bonanjo, Douala',
        city: 'Douala',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        viewCount: 67,
        contactCount: 11,
      ),
    ];
    notifyListeners();
  }

  List<ScrapListing> filterListings({
    MetalType? metalType,
    String? city,
    double? maxPricePerKg,
    double? minWeightKg,
    String? query,
  }) {
    return activeListings.where((listing) {
      if (metalType != null && listing.metalType != metalType) return false;
      if (city != null && city.isNotEmpty && listing.city.toLowerCase() != city.toLowerCase()) return false;
      if (maxPricePerKg != null && listing.pricePerKg > maxPricePerKg) return false;
      if (minWeightKg != null && listing.weightKg < minWeightKg) return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!listing.title.toLowerCase().contains(q) &&
            !listing.description.toLowerCase().contains(q) &&
            !listing.sellerName.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Future<void> addListing(ScrapListing listing) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _listings.insert(0, listing);
    _isLoading = false;
    notifyListeners();
  }

  ScrapListing? getListingById(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  void incrementViewCount(String id) {
    final idx = _listings.indexWhere((l) => l.id == id);
    if (idx != -1) {
      _listings[idx] = _listings[idx].copyWith(viewCount: _listings[idx].viewCount + 1);
      notifyListeners();
    }
  }
}
