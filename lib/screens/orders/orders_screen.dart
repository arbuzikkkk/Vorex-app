import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/glass_card.dart';
import '../chat/chat_screen.dart';

class OrdersScreen extends StatefulWidget {
  final AppUser? user;
  const OrdersScreen({super.key, required this.user});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final user = widget.user;
    _future = user == null ? Future.value([]) : OrderService().listForUser(user.id);
  }

  Future<void> _dispute(Order order) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VorexColors.bgPanel,
        title: const Text('Жалоба на сделку'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Опишите проблему...'),
          style: const TextStyle(color: VorexColors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty) {
      await OrderService().fileDispute(order.id, reason);
      setState(_load);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Жалоба отправлена администратору'), backgroundColor: VorexColors.accentBright),
      );
    }
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.active:
        return VorexColors.accentBright;
      case OrderStatus.completed:
        return VorexColors.success;
      case OrderStatus.disputed:
        return Colors.orange;
      case OrderStatus.refunded:
        return VorexColors.danger;
      case OrderStatus.cancelled:
        return VorexColors.greyText;
    }
  }

  String _statusLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.active:
        return 'Активен';
      case OrderStatus.completed:
        return 'Завершён';
      case OrderStatus.disputed:
        return 'Спор';
      case OrderStatus.refunded:
        return 'Возврат';
      case OrderStatus.cancelled:
        return 'Отменён';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return SafeArea(
      child: RefreshIndicator(
        color: VorexColors.accentBright,
        onRefresh: () async {
          setState(_load);
          await _future;
        },
        child: FutureBuilder<List<Order>>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: VorexColors.accentBright));
            }
            final orders = snapshot.data!;
            if (orders.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('У вас пока нет заказов', style: TextStyle(color: VorexColors.greyText))),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final o = orders[i];
                final isBuyer = o.buyerId == user?.id;
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isBuyer ? 'Покупка' : 'Продажа', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(o.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_statusLabel(o.status),
                                style: TextStyle(color: _statusColor(o.status), fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${o.price.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ChatScreen(order: o, currentUserId: user!.id)),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                            label: const Text('Чат'),
                          ),
                          if (o.status == OrderStatus.active)
                            TextButton.icon(
                              onPressed: () => _dispute(o),
                              icon: const Icon(Icons.flag_outlined, size: 16, color: VorexColors.danger),
                              label: const Text('Жалоба', style: TextStyle(color: VorexColors.danger)),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
