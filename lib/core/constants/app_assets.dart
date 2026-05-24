/// Bundled images and icons (offline-safe, theme-aligned).
abstract final class AppAssets {
  static const products = <String>[
    'assets/images/products/product_1.jpg',
    'assets/images/products/product_2.jpg',
    'assets/images/products/product_3.jpg',
    'assets/images/products/product_4.jpg',
    'assets/images/products/product_5.jpg',
    'assets/images/products/product_6.jpg',
    'assets/images/products/product_7.jpg',
    'assets/images/products/product_8.jpg',
  ];

  static const onboarding = <String>[
    'assets/images/onboarding/onboarding_1.jpg',
    'assets/images/onboarding/onboarding_2.jpg',
    'assets/images/onboarding/onboarding_3.jpg',
  ];

  static const heroBanner = 'assets/images/ui/hero_banner.jpg';
  static const avatarDefault = 'assets/images/ui/avatar_default.jpg';

  static String productImage(String id) {
    final index = int.tryParse(id);
    if (index == null || index < 1 || index > products.length) {
      return products.first;
    }
    return products[index - 1];
  }
}
