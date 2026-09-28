import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../data/mock_data.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  String _selectedCategory = 'all'; // 'all', 'sunset', 'ao', 'quan'
  String _searchQuery = '';
  String _sortBy = 'newest'; // 'newest', 'price_asc', 'price_desc'
  final Set<int> _wishlistIds = {};

  ProductProvider() {
    _products = List.from(MockData.initialProducts);
  }

  List<Product> get allProducts => _products;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  Set<int> get wishlistIds => _wishlistIds;

  bool isFavorite(int productId) => _wishlistIds.contains(productId);

  void toggleFavorite(int productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    List<Product> list = List.from(_products);

    // 1. Filter by Category
    if (_selectedCategory == 'sunset') {
      list = list.where((p) => p.collection == 'sunset').toList();
    } else if (_selectedCategory == 'ao') {
      list = list.where((p) => p.type == 'ao').toList();
    } else if (_selectedCategory == 'quan') {
      list = list.where((p) => p.type == 'quan').toList();
    }

    // 2. Filter by Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            (p.description?.toLowerCase().contains(q) ?? false) ||
            (p.tag?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // 3. Sort
    if (_sortBy == 'price_asc') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else {
      // newest by id desc
      list.sort((a, b) => b.id.compareTo(a.id));
    }

    return list;
  }

  List<Product> get sunsetCollection {
    return _products.where((p) => p.collection == 'sunset').toList();
  }

  List<Product> get featuredProducts {
    return _products.where((p) => p.isFeatured || (p.tag != null)).toList();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
