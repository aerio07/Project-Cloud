class Place {

  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String description;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  factory Place.fromJson(Map<String, dynamic> json) {

    return Place(
      id: json['id'] ?? 0,

      name: json['name'] ?? '',

      address: json['address'] ?? '',

      latitude:
          (json['latitude'] as num).toDouble(),

      longitude:
          (json['longitude'] as num).toDouble(),

      description:
          json['description'] ?? '',
    );
  }
}