import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/product.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/widgets/luxe_image.dart';
import '../../shared/widgets/product_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final all = app.products;
    final categories = app.categories;
    var filtered =
        _category == 'All' ? List<Product>.from(all) : all.where((p) => p.category == _category).toList();
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    final featured = filtered.take(4).toList();
    final best = all.length > 4 ? ([...all]..sort((a, b) => b.rating.compareTo(a.rating))).take(4).toList() : <Product>[];
    final showStatus = app.catalogLoading || app.catalogError != null || featured.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LuxeJewel', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text('Discover Timeless Beauty', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Material(
                        color: AppColors.bgSecondary,
                        shape: const CircleBorder(),
                        child: Tooltip(
                          message: 'Order updates',
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => context.push('/orders'),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(Icons.notifications_none_rounded, size: 22),
                                  if (app.orders.isNotEmpty)
                                    const Positioned(
                                      right: -1,
                                      top: -1,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                                        child: SizedBox(width: 8, height: 8),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) => context.push('/products?q=${Uri.encodeQueryComponent(v.trim())}'),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search jewelry…',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/products'),
                    child: SizedBox(
                      height: 190,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          const LuxeImage(
                            source: AppAssets.heroBanner,
                            semanticLabel: 'New collection banner',
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.bgPrimary.withOpacity(0.92),
                                  AppColors.bgPrimary.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('New Collection', style: Theme.of(context).textTheme.headlineSmall),
                                const SizedBox(height: 6),
                                Text(
                                  'Exclusive Designs',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gold),
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: () => context.push('/products'),
                                  child: const Text('Explore Now'),
                                ),
                              ],
                            ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final c = categories[i];
                  final active = _category == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: active,
                    onSelected: (_) => setState(() => _category = c),
                    selectedColor: AppColors.gold,
                    labelStyle: TextStyle(
                      color: active ? AppColors.bgPrimary : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.bgSecondary,
                    side: const BorderSide(color: AppColors.divider),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Featured Products', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  TextButton(
                    onPressed: () => context.push('/products'),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: showStatus
                ? CatalogStatusSliver(
                    loading: app.catalogLoading,
                    error: app.catalogError,
                    onRetry: app.loadCatalog,
                  )
                : ProductSliverGrid(products: featured),
          ),
          if (best.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
                child: Text('Best Sellers', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              sliver: ProductSliverGrid(products: best),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
