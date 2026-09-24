import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton_loader.dart';
import 'product_detail_screen.dart';

const kCategories = ['Все', 'Игровые аккаунты', 'Внутриигровая валюта', 'Подписки', 'Ключи', 'Прочее'];

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _category = 'Все';
  final _search = TextEditingController();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductService().listActive();
  }

  void _reload() {
    setState(() => _future = ProductService().listActive(category: _category, query: _search.text));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _search,
              onSubmitted: (_) => _reload(),
              decoration: InputDecoration(
                hintText: 'Поиск товаров...',
                prefixIcon: const Icon(Icons.search, color: VorexColors.greyText),
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward, size: 18), onPressed: _reload),
              ),
              style: const TextStyle(color: VorexColors.white),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = kCategories[i];
                final selected = cat == _category;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _category = cat);
                    _reload();
                  },
                  selectedColor: VorexColors.accent,
                  backgroundColor: VorexColors.bgPanel,
                  labelStyle: TextStyle(color: selected ? Colors.white : VorexColors.greyText, fontSize: 12),
                  shape: const StadiumBorder(side: BorderSide(color: VorexColors.glassBorder)),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    children: List.generate(6, (_) => const ProductCardSkeleton()),
                  );
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Center(child: Text('Ничего не найдено', style: TextStyle(color: VorexColors.greyText)));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) => ProductCard(
                    product: items[i],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: items[i])),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
