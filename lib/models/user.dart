enum UserType {
  seller,   // Scrap collectors / people with metal waste
  buyer,    // Manufacturers, recyclers, workshops
  both,
}

extension UserTypeExt on UserType {
  String get displayName {
    switch (this) {
      case UserType.seller: return 'Scrap Seller';
      case UserType.buyer: return 'Metal Buyer / Manufacturer';
      case UserType.both: return 'Seller & Buyer';
    }
  }

  String get description {
    switch (this) {
      case UserType.seller: return 'I collect and sell metal scraps';
      case UserType.buyer: return 'I buy metals to make products';
      case UserType.both: return 'I do both';
    }
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final UserType userType;
  final String city;
  final String? businessName;
  final String? businessDescription;
  final double rating;
  final int totalRatings;
  final int totalListings;
  final int totalSales;
  final bool isVerified;
  final DateTime joinedAt;
  final List<String> preferredMetals; // For buyers

  AppUser({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.userType,
    required this.city,
    this.businessName,
    this.businessDescription,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.totalListings = 0,
    this.totalSales = 0,
    this.isVerified = false,
    required this.joinedAt,
    this.preferredMetals = const [],
  });

  String get displayName => businessName ?? fullName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'avatarUrl': avatarUrl,
    'userType': userType.name,
    'city': city,
    'businessName': businessName,
    'businessDescription': businessDescription,
    'rating': rating,
    'totalRatings': totalRatings,
    'totalListings': totalListings,
    'totalSales': totalSales,
    'isVerified': isVerified,
    'joinedAt': joinedAt.toIso8601String(),
    'preferredMetals': preferredMetals,
  };
}
