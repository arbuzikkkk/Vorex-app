import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/product.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../widgets/glass_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _buying = false;

  Future<void> _buy() async {
    setState(() => _buying = true);
    final user = await AuthService().currentUser();
    if (user == null) return;
    try {
      await OrderService().purchase(product: widget.product, buyerId: user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Покупка совершена! Смотрите вкладку «Заказы».'), backgroundColor: VorexColors.success),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: VorexColors.danger),
      );
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: VorexColors.bgDeep,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: VorexColors.bgPanel,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${p.id}',
                child: p.photoPaths.isNotEmpty && File(p.photoPaths.first).existsSync()
                    ? Image.file(File(p.photoPaths.first), fit: BoxFit.cover)
                    : Container(
                        color: VorexColors.bgPanel,
                        child: const Icon(Icons.videogame_asset_rounded, size: 60, color: VorexColors.greyText),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(p.category, style: const TextStyle(color: VorexColors.greyText, fontSize: 13)),
                  const SizedBox(height: 16),
                  Text('${p.price.toStringAsFixed(0)} ₽',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: VorexColors.accentBright)),
                  const SizedBox(height: 20),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Описание', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(p.description, style: const TextStyle(color: VorexColors.greyText, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (p.status == ProductStatus.active && !_buying) ? _buy : null,
              child: _buying
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(p.status == ProductStatus.active ? 'Купить сейчас' : 'Товар недоступен'),
            ),
          ),
        ),
      ),
    );
  }
}
