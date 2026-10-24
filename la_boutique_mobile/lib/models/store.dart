/// Cửa hàng/chi nhánh, khớp StoreResponse của BE:
/// { id, storeName, address, phone, openingHours, latitude, longitude, imageUrl, status, createdAt, updatedAt }.
///
/// `latitude`/`longitude` là double → cắm thẳng vào LatLng(lat, lng) của flutter_map.
class StoreModel {
  final String id;
  final String storeName;
  final String address;
  final String phone;
  final String openingHours;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String status; // BE chỉ trả ACTIVE ở /stores (HIDDEN/DELETED đã bị lọc)

  const StoreModel({
    required this.id,
    required this.storeName,
    required this.address,
    required this.phone,
    required this.openingHours,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.status = 'ACTIVE',
  });

  bool get isOpen => status.toUpperCase() == 'ACTIVE';

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id']?.toString() ?? '',
      storeName: (json['storeName'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      openingHours: (json['openingHours'] ?? '').toString(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      status: (json['status'] ?? 'ACTIVE').toString(),
    );
  }
}
