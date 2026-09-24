import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../services/user_service.dart';
import '../../services/product_service.dart';
import '../../services/order_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/glass_card.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VorexColors.bgDeep,
      appBar: AppBar(
        title: const Text('Панель администратора'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          indicatorColor: VorexColors.accentBright,
          labelColor: VorexColors.white,
          unselectedLabelColor: VorexColors.greyText,
          tabs: const [
            Tab(text: 'Статистика'),
            Tab(text: 'Жалобы'),
            Tab(text: 'Товары'),
            Tab(text: 'Пользователи'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _StatsTab(),
          _DisputesTab(),
          _ProductsTab(),
          _UsersTab(),
        ],
      ),
    );
  }
}

class _StatsTab extends StatefulWidget {
  const _StatsTab();
  @override
  State<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<_StatsTab> {
  final _commission = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: SettingsService().profitStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: VorexColors.accentBright));
        final stats = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Оборот площадки', style: TextStyle(color: VorexColors.greyText, fontSize: 12)),
                  Text('${stats['totalVolume']!.toStringAsFixed(0)} ₽',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  const Text('Доход от комиссии (оценка)', style: TextStyle(color: VorexColors.greyText, fontSize: 12)),
                  Text('${stats['estimatedCommissionRevenue']!.toStringAsFixed(0)} ₽',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: VorexColors.accentBright)),
                  const SizedBox(height: 12),
                  const Text('Количество заказов', style: TextStyle(color: VorexColors.greyText, fontSize: 12)),
                  Text(stats['orderCount']!.toStringAsFixed(0), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<double>(
              future: SettingsService().getCommissionPercent(),
              builder: (context, snap) {
                if (snap.hasData && _commission.text.isEmpty) {
                  _commission.text = snap.data!.toStringAsFixed(1);
                }
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Комиссия площадки (%)', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commission,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: VorexColors.white),
                              decoration: const InputDecoration(hintText: '5'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              final v = double.tryParse(_commission.text.replaceAll(',', '.'));
                              if (v == null) return;
                              await SettingsService().setCommissionPercent(v);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Комиссия обновлена'), backgroundColor: VorexColors.success),
                              );
                            },
                            child: const Text('Сохранить'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _DisputesTab extends StatefulWidget {
  const _DisputesTab();
  @override
  State<_DisputesTab> createState() => _DisputesTabState();
}

class _DisputesTabState extends State<_DisputesTab> {
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _future = OrderService().listAllForAdmin();
  }

  void _reload() => setState(() => _future = OrderService().listAllForAdmin());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: VorexColors.accentBright));
        final disputed = snapshot.data!.where((o) => o.status == OrderStatus.disputed).toList();
        if (disputed.isEmpty) {
          return const Center(child: Text('Активных жалоб нет', style: TextStyle(color: VorexColors.greyText)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: disputed.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final o = disputed[i];
            return GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Заказ #${o.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Причина: ${o.disputeReason ?? "-"}', style: const TextStyle(color: VorexColors.greyText)),
                  const SizedBox(height: 6),
                  Text('${o.price.toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await OrderService().refund(o.id);
                          _reload();
                        },
                        child: const Text('Вернуть деньги'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await OrderService().markCompleted(o.id);
                          _reload();
                        },
                        child: const Text('Отклонить жалобу'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductsTab extends StatefulWidget {
  const _ProductsTab();
  @override
  State<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<_ProductsTab> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductService().listAllForAdmin();
  }

  void _reload() => setState(() => _future = ProductService().listAllForAdmin());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: VorexColors.accentBright));
        final products = snapshot.data!;
        if (products.isEmpty) {
          return const Center(child: Text('Товаров нет', style: TextStyle(color: VorexColors.greyText)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final p = products[i];
            return GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${p.price.toStringAsFixed(0)} ₽ · ${p.status.name}',
                            style: const TextStyle(color: VorexColors.greyText, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: VorexColors.danger),
                    onPressed: () async {
                      await ProductService().deleteProduct(p.id);
                      _reload();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  late Future<List<AppUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = UserService().listAll();
  }

  void _reload() => setState(() => _future = UserService().listAll());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppUser>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: VorexColors.accentBright));
        final users = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final u = users[i];
            return GlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.username, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${u.balance.toStringAsFixed(0)} ₽${u.isBanned ? " · ЗАБЛОКИРОВАН" : ""}',
                            style: TextStyle(color: u.isBanned ? VorexColors.danger : VorexColors.greyText, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: !u.isBanned,
                    activeColor: VorexColors.success,
                    onChanged: (v) async {
                      await UserService().setBanned(u.id, !v);
                      _reload();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
