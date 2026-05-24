import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../data/products_data.dart';
import '../../domain/models/product.dart';
import '../../shared/widgets/product_card.dart';

enum _Sort { featured, priceLow, priceHigh, rating }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _category = 'All';
  _Sort _sort = _Sort.featured;

  List<Product> _sorted(List<Product> input) {
    final list = List<Product>.from(input);
    switch (_sort) {
      case _Sort.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _Sort.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _Sort.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _Sort.featured:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<AppState>().catalog.all;
    final base = _category == 'All' ? all : all.where((p) => p.category == _category).toList();
    final sorted = _sorted(base);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgPrimary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            title: const Text('All Products'),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kCategories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final c = kCategories[i];
                      final active = _category == c;
                      return FilterChip(
                        label: Text(c, style: TextStyle(fontSize: 13, color: active ? AppColors.bgPrimary : null)),
                        selected: active,
                        onSelected: (_) => setState(() => _category = c),
                        selectedColor: AppColors.gold,
                        backgroundColor: AppColors.bgSecondary,
                        checkmarkColor: AppColors.bgPrimary,
                        side: const BorderSide(color: AppColors.divider),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${sorted.length} products found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<_Sort>(
                      value: _sort,
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: AppColors.bgSecondary,
                      items: const [
                        DropdownMenuItem(value: _Sort.featured, child: Text('Featured')),
                        DropdownMenuItem(value: _Sort.priceLow, child: Text('Price: Low to High')),
                        DropdownMenuItem(value: _Sort.priceHigh, child: Text('Price: High to Low')),
                        DropdownMenuItem(value: _Sort.rating, child: Text('Highest Rated')),
                      ],
                      onChanged: (v) => setState(() => _sort = v ?? _Sort.featured),
                    ),
                  ),
                ],
              ),
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
                (context, i) => ProductCard(product: sorted[i]),
                childCount: sorted.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
