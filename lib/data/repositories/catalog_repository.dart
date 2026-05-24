import '../../domain/models/product.dart';
import '../products_data.dart';

/// Read-only product catalog. Swap for a remote API without touching UI.
abstract class CatalogRepository {
  List<Product> get all;
  List<String> get categories;
  Product? byId(String id);
}

class InMemoryCatalogRepository implements CatalogRepository {
  @override
  List<Product> get all => List.unmodifiable(kProducts);

  @override
  List<String> get categories => List.unmodifiable(kCategories);

  @override
  Product? byId(String id) {
    try {
      return kProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
