import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../data/products_data.dart';
import '../../domain/models/product.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/widgets/luxe_image.dart';
import '../../shared/widgets/product_card.dart';

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
    final all = context.watch<AppState>().catalog.all;
    var filtered =
        _category == 'All' ? List<Product>.from(all) : all.where((p) => p.category == _category).toList();
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    final featured = filtered.take(4).toList();
    final best = all.length > 4 ? all.sublist(4) : <Product>[];

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
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(Icons.notifications_none_rounded, size: 22),
                                Positioned(
                                  right: -1,
                                  top: -1,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                                    child: const SizedBox(width: 8, height: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
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
                itemCount: kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final c = kCategories[i];
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
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.54,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => ProductCard(product: featured[i]),
                childCount: featured.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
              child: Text('Best Sellers', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.54,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => ProductCard(product: best[i]),
                childCount: best.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
