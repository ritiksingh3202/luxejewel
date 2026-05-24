import '../core/constants/app_assets.dart';
import '../domain/models/product.dart';

/// Static catalog (same items as the React `products.ts`).
final List<Product> kProducts = [
  Product(
    id: '1',
    name: 'Diamond Solitaire Ring',
    price: 2499,
    image: AppAssets.products[0],
    category: 'Rings',
    rating: 4.8,
    description:
        'Exquisite 18K white gold solitaire ring featuring a brilliant 1-carat diamond. Timeless elegance for your special moments.',
    material: '18K White Gold',
  ),
  Product(
    id: '2',
    name: 'Gold Pearl Necklace',
    price: 1899,
    image: AppAssets.products[1],
    category: 'Necklaces',
    rating: 4.9,
    description:
        'Luxurious 22K gold necklace adorned with natural pearls. A statement piece that exudes sophistication.',
    material: '22K Gold',
  ),
  Product(
    id: '3',
    name: 'Emerald Drop Earrings',
    price: 1599,
    image: AppAssets.products[2],
    category: 'Earrings',
    rating: 4.7,
    description:
        'Stunning emerald drop earrings set in platinum. Perfect blend of classic and contemporary design.',
    material: 'Platinum',
  ),
  Product(
    id: '4',
    name: 'Tennis Bracelet',
    price: 3299,
    image: AppAssets.products[3],
    category: 'Bracelets',
    rating: 5.0,
    description:
        'Classic diamond tennis bracelet featuring 50 brilliant-cut diamonds in 18K white gold.',
    material: '18K White Gold',
  ),
  Product(
    id: '5',
    name: 'Rose Gold Band Ring',
    price: 899,
    image: AppAssets.products[4],
    category: 'Rings',
    rating: 4.6,
    description:
        'Delicate rose gold band with intricate detailing. Perfect for everyday elegance.',
    material: '14K Rose Gold',
  ),
  Product(
    id: '6',
    name: 'Sapphire Pendant',
    price: 2199,
    image: AppAssets.products[5],
    category: 'Necklaces',
    rating: 4.8,
    description:
        'Royal blue sapphire pendant surrounded by diamonds, set in white gold.',
    material: '18K White Gold',
  ),
  Product(
    id: '7',
    name: 'Diamond Hoop Earrings',
    price: 1299,
    image: AppAssets.products[6],
    category: 'Earrings',
    rating: 4.9,
    description:
        'Elegant diamond-studded hoop earrings in yellow gold. Timeless style for any occasion.',
    material: '18K Yellow Gold',
  ),
  Product(
    id: '8',
    name: 'Charm Bracelet',
    price: 1799,
    image: AppAssets.products[7],
    category: 'Bracelets',
    rating: 4.7,
    description:
        'Sophisticated charm bracelet with symbolic gold charms. Tell your story in style.',
    material: '22K Gold',
  ),
];

const List<String> kCategories = [
  'All',
  'Rings',
  'Necklaces',
  'Earrings',
  'Bracelets',
];
