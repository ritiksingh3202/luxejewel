import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/app_state.dart';
import '../../core/formatting/money.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/product.dart';
import '../../router/nav.dart';
import '../../shared/widgets/luxe_button.dart';
import '../../shared/widgets/product_grid.dart';

enum _Sort { featured, priceLow, priceHigh, rating }

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _category = 'All';
  _Sort _sort = _Sort.featured;
  late String _query = widget.initialQuery ?? '';
  RangeValues? _price;
  bool _inStockOnly = false;

  bool get _hasFilters => _query.isNotEmpty || _price != null || _inStockOnly;

  List<Product> _apply(List<Product> input) {
    final q = _query.trim().toLowerCase();
    final list = input.where((p) {
      if (_category != 'All' && p.category != _category) return false;
      if (q.isNotEmpty &&
          !p.name.toLowerCase().contains(q) &&
          !p.description.toLowerCase().contains(q) &&
          !(p.material ?? '').toLowerCase().contains(q)) {
        return false;
      }
      if (_price != null && (p.price < _price!.start || p.price > _price!.end)) return false;
      if (_inStockOnly && !p.inStock) return false;
      return true;
    }).toList();
    switch (_sort) {
      case _Sort.priceLow:
        list.sort((a, b) => a.priceCents.compareTo(b.priceCents));
      case _Sort.priceHigh:
        list.sort((a, b) => b.priceCents.compareTo(a.priceCents));
      case _Sort.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case _Sort.featured:
        break;
    }
    return list;
  }

  Future<void> _openFilters(List<Product> all) async {
    if (all.isEmpty) return;
    final maxPrice = all.map((p) => p.price).reduce((a, b) => a > b ? a : b).ceilToDouble();
    final searchCtrl = TextEditingController(text: _query);
    var range = _price ?? RangeValues(0, maxPrice);
    var inStock = _inStockOnly;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filters', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search name, material…',
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Price: ${usd.format(range.start)} – ${usd.format(range.end)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              RangeSlider(
                values: range,
                min: 0,
                max: maxPrice,
                divisions: 20,
                activeColor: AppColors.gold,
                onChanged: (v) => setSheet(() => range = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: inStock,
                activeThumbColor: AppColors.gold,
                title: const Text('In stock only'),
                onChanged: (v) => setSheet(() => inStock = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: LuxeButton(
                      label: 'Reset',
                      variant: LuxeButtonVariant.outline,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LuxeButton(label: 'Apply', onPressed: () => Navigator.pop(context, true)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || applied == null) return;
    setState(() {
      if (applied) {
        _query = searchCtrl.text.trim();
        _price = (range.start <= 0 && range.end >= maxPrice) ? null : range;
        _inStockOnly = inStock;
      } else {
        _query = '';
        _price = null;
        _inStockOnly = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final all = app.products;
    final categories = app.categories;
    final sorted = _apply(all);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgPrimary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => context.popOrGo('/home'),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            title: const Text('All Products'),
            actions: [
              IconButton(
                tooltip: 'Filters',
                onPressed: () => _openFilters(all),
                icon: Badge(
                  isLabelVisible: _hasFilters,
                  backgroundColor: AppColors.gold,
                  smallSize: 8,
                  child: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 10),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final c = categories[i];
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
                      _query.isEmpty ? '${sorted.length} products found' : '${sorted.length} results for "$_query"',
                      overflow: TextOverflow.ellipsis,
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
            sliver: (app.catalogLoading || app.catalogError != null || sorted.isEmpty)
                ? CatalogStatusSliver(
                    loading: app.catalogLoading,
                    error: app.catalogError,
                    onRetry: app.loadCatalog,
                  )
                : ProductSliverGrid(products: sorted),
          ),
        ],
      ),
    );
  }
}
