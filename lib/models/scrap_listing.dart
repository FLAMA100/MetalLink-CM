enum MetalType {
  iron,
  steel,
  copper,
  aluminum,
  brass,
  zinc,
  lead,
  mixed,
}

enum ListingStatus {
  active,
  sold,
  reserved,
  expired,
}

extension MetalTypeExt on MetalType {
  String get displayName {
    switch (this) {
      case MetalType.iron: return 'Iron (Fer)';
      case MetalType.steel: return 'Steel (Acier)';
      case MetalType.copper: return 'Copper (Cuivre)';
      case MetalType.aluminum: return 'Aluminum (Aluminium)';
      case MetalType.brass: return 'Brass (Laiton)';
      case MetalType.zinc: return 'Zinc';
      case MetalType.lead: return 'Lead (Plomb)';
      case MetalType.mixed: return 'Mixed Metals';
    }
  }

  String get emoji {
    switch (this) {
      case MetalType.iron: return '⚙️';
      case MetalType.steel: return '🔩';
      case MetalType.copper: return '🟠';
      case MetalType.aluminum: return '⬜';
      case MetalType.brass: return '🟡';
      case MetalType.zinc: return '🔘';
      case MetalType.lead: return '⬛';
      case MetalType.mixed: return '🗃️';
    }
  }

  /// Approximate price range in CFA per kg
  String get priceRangeCFA {
    switch (this) {
      case MetalType.copper: return '1,500 – 2,500 CFA/kg';
      case MetalType.aluminum: return '400 – 700 CFA/kg';
      case MetalType.steel: return '100 – 200 CFA/kg';
      case MetalType.iron: return '80 – 150 CFA/kg';
      case MetalType.brass: return '800 – 1,400 CFA/kg';
      case MetalType.zinc: return '500 – 900 CFA/kg';
      case MetalType.lead: return '300 – 600 CFA/kg';
      case MetalType.mixed: return '100 – 300 CFA/kg';
    }
  }
}

class ScrapListing {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String? sellerAvatarUrl;
  final double sellerRating;

  final String title;
  final String description;
  final MetalType metalType;
  final double weightKg;
  final double pricePerKg; // CFA Francs
  double get totalPrice => weightKg * pricePerKg;

  final List<String> photoUrls;
  final String? voiceNoteUrl;

  // Location
  final double latitude;
  final double longitude;
  final String locationName; // e.g. "Biyem-Assi, Yaoundé"
  final String city;

  final ListingStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Engagement
  final int viewCount;
  final int contactCount;
  final bool isUrgent;

  ScrapListing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    this.sellerAvatarUrl,
    this.sellerRating = 0.0,
    required this.title,
    required this.description,
    required this.metalType,
    required this.weightKg,
    required this.pricePerKg,
    this.photoUrls = const [],
    this.voiceNoteUrl,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.city,
    this.status = ListingStatus.active,
    required this.createdAt,
    this.updatedAt,
    this.viewCount = 0,
    this.contactCount = 0,
    this.isUrgent = false,
  });

  ScrapListing copyWith({
    ListingStatus? status,
    int? viewCount,
    int? contactCount,
  }) {
    return ScrapListing(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      sellerAvatarUrl: sellerAvatarUrl,
      sellerRating: sellerRating,
      title: title,
      description: description,
      metalType: metalType,
      weightKg: weightKg,
      pricePerKg: pricePerKg,
      photoUrls: photoUrls,
      voiceNoteUrl: voiceNoteUrl,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      city: city,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      viewCount: viewCount ?? this.viewCount,
      contactCount: contactCount ?? this.contactCount,
      isUrgent: isUrgent,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sellerId': sellerId,
    'sellerName': sellerName,
    'sellerPhone': sellerPhone,
    'sellerAvatarUrl': sellerAvatarUrl,
    'sellerRating': sellerRating,
    'title': title,
    'description': description,
    'metalType': metalType.name,
    'weightKg': weightKg,
    'pricePerKg': pricePerKg,
    'photoUrls': photoUrls,
    'voiceNoteUrl': voiceNoteUrl,
    'latitude': latitude,
    'longitude': longitude,
    'locationName': locationName,
    'city': city,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'viewCount': viewCount,
    'contactCount': contactCount,
    'isUrgent': isUrgent,
  };

  factory ScrapListing.fromJson(Map<String, dynamic> json) => ScrapListing(
    id: json['id'],
    sellerId: json['sellerId'],
    sellerName: json['sellerName'],
    sellerPhone: json['sellerPhone'],
    sellerAvatarUrl: json['sellerAvatarUrl'],
    sellerRating: (json['sellerRating'] as num).toDouble(),
    title: json['title'],
    description: json['description'],
    metalType: MetalType.values.firstWhere((e) => e.name == json['metalType']),
    weightKg: (json['weightKg'] as num).toDouble(),
    pricePerKg: (json['pricePerKg'] as num).toDouble(),
    photoUrls: List<String>.from(json['photoUrls'] ?? []),
    voiceNoteUrl: json['voiceNoteUrl'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    locationName: json['locationName'],
    city: json['city'],
    status: ListingStatus.values.firstWhere((e) => e.name == json['status']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    viewCount: json['viewCount'] ?? 0,
    contactCount: json['contactCount'] ?? 0,
    isUrgent: json['isUrgent'] ?? false,
  );
}
