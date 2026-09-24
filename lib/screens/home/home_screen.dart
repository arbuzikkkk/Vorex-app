import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton_loader.dart';
import '../catalog/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser? user;
  final VoidCallback onUserChanged;

  const HomeScreen({super.key, required this.user, required this.onUserChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _featured;

  @override
  void initState() {
    super.initState();
    _featured = ProductService().listActive();
  }

  Future<void> _refresh() async {
    setState(() => _featured = ProductService().listActive());
    await _featured;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return SafeArea(
      child: RefreshIndicator(
        color: VorexColors.accentBright,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Привет, ${user?.username ?? ''} 👋',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Баланс', style: TextStyle(color: VorexColors.greyText, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${user?.balance.toStringAsFixed(0) ?? 0} ₽',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Icon(Icons.account_balance_wallet_rounded, color: VorexColors.accentBright, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Новые товары', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            FutureBuilder<List<Product>>(
              future: _featured,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.72,
                    children: List.generate(4, (_) => const ProductCardSkeleton()),
                  );
                }
                final items = snapshot.data!.take(8).toList();
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('Пока нет товаров', style: TextStyle(color: VorexColors.greyText)),
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
      ),
    );
  }
}
