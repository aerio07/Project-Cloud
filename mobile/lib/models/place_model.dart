// Helper untuk mem-parse nilai double secara aman dari database (bisa berupa String decimal, num, atau null)
double _doubleParse(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// Helper untuk mem-parse nilai int secara aman
int _intParse(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class Category {
  final int id;
  final String name;
  final String icon;

  Category({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _intParse(json['id']),
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class Fuel {
  final int id;
  final String brand;
  final String name;
  final String octane;
  final double nationalPrice;
  final double price;
  final bool isAvailable;

  Fuel({
    required this.id,
    required this.brand,
    required this.name,
    required this.octane,
    required this.nationalPrice,
    required this.price,
    required this.isAvailable,
  });

  factory Fuel.fromJson(Map<String, dynamic> json) {
    final pivot = json['pivot'] as Map<String, dynamic>?;
    final price = pivot?['price'] ?? json['price'] ?? json['national_price'];
    final available = pivot?['is_available'] ?? json['is_available'] ?? true;

    return Fuel(
      id: _intParse(json['id']),
      brand: json['brand'] ?? '',
      name: json['name'] ?? '',
      octane: json['octane'] ?? '',
      nationalPrice: _doubleParse(json['national_price'] ?? json['price']),
      price: _doubleParse(price),
      isAvailable: available == true || available == 1 || available == '1',
    );
  }
}

class Facility {
  final int id;
  final String name;
  final String icon;

  Facility({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: _intParse(json['id']),
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class Review {
  final int id;
  final String userName;
  final int rating;
  final String comment;
  final String createdAt;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: _intParse(json['id']),
      userName: json['user_name'] ?? 'Anonim',
      rating: _intParse(json['rating']),
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class Place {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final double rating;
  final String photoUrl;
  final List<String> images;
  final String openingHours;
  final Category? category;
  final List<Fuel> fuels;
  final List<Facility> facilities;
  final List<Review> reviews;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.rating,
    required this.photoUrl,
    required this.images,
    required this.openingHours,
    this.category,
    required this.fuels,
    required this.facilities,
    required this.reviews,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    final fuelsList = json['fuels'] is List ? json['fuels'] as List : null;
    final facilitiesList = json['facilities'] is List ? json['facilities'] as List : null;
    final reviewsList = json['reviews'] is List ? json['reviews'] as List : null;
    final imagesList = json['images'] is List
        ? (json['images'] as List).map((e) {
            if (e is Map) {
              return e['photo_url']?.toString() ?? '';
            }
            return e.toString();
          }).where((url) => url.isNotEmpty).toList()
        : <String>[];

    return Place(
      id: _intParse(json['id']),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: _doubleParse(json['latitude']),
      longitude: _doubleParse(json['longitude']),
      description: json['description'] ?? '',
      rating: _doubleParse(json['rating']),
      photoUrl: json['photo_url'] ?? '',
      images: imagesList,
      openingHours: json['opening_hours'] ?? '24 Jam',
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      fuels: fuelsList != null ? fuelsList.map((e) => Fuel.fromJson(e)).toList() : [],
      facilities: facilitiesList != null ? facilitiesList.map((e) => Facility.fromJson(e)).toList() : [],
      reviews: reviewsList != null ? reviewsList.map((e) => Review.fromJson(e)).toList() : [],
    );
  }
}
