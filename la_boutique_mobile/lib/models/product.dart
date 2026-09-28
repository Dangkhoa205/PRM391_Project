class Product {
  final int id;
  final String name;
  final String slug;
  final double price;
  final double? originalPrice;
  final String type; // 'ao' or 'quan'
  final bool isSummer;
  final bool isFeatured;
  final String collection; // 'sunset' or 'regular'
  final String img;
  final List<String> gallery;
  final String? tag;
  final String? description;
  final String? material;
  final String? careInstructions;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    this.originalPrice,
    required this.type,
    this.isSummer = false,
    this.isFeatured = false,
    required this.collection,
    required this.img,
    required this.gallery,
    this.tag,
    this.description,
    this.material,
    this.careInstructions,
  });

  int get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  // Convert image path from web (/images/products/...) to flutter asset or network URL
  String get assetPath {
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return img;
    }
    if (img.startsWith('assets/')) {
      return img;
    }
    final cleaned = img.startsWith('/') ? img.substring(1) : img;
    if (cleaned.startsWith('assets/')) {
      return cleaned;
    }
    if (cleaned.startsWith('images/')) {
      return 'assets/$cleaned';
    }
    return 'assets/images/products/$cleaned';
  }

  List<String> get assetGallery {
    return gallery.map((g) {
      if (g.startsWith('http://') || g.startsWith('https://')) {
        return g;
      }
      if (g.startsWith('assets/')) {
        return g;
      }
      final cleaned = g.startsWith('/') ? g.substring(1) : g;
      if (cleaned.startsWith('assets/')) {
        return cleaned;
      }
      if (cleaned.startsWith('images/')) {
        return 'assets/$cleaned';
      }
      return 'assets/images/products/$cleaned';
    }).toList();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      type: json['type'] as String,
      isSummer: json['isSummer'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      collection: json['collection'] as String? ?? 'regular',
      img: json['img'] as String,
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tag: json['tag'] as String?,
      description: json['description'] as String?,
      material: json['material'] as String?,
      careInstructions: json['careInstructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'price': price,
      'originalPrice': originalPrice,
      'type': type,
      'isSummer': isSummer,
      'isFeatured': isFeatured,
      'collection': collection,
      'img': img,
      'gallery': gallery,
      'tag': tag,
      'description': description,
      'material': material,
      'careInstructions': careInstructions,
    };
  }
}
