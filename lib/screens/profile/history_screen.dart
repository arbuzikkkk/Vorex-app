import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../models/transaction.dart';
import '../../services/wallet_service.dart';
import '../../widgets/glass_card.dart';

class HistoryScreen extends StatelessWidget {
  final AppUser user;
  const HistoryScreen({super.key, required this.user});

  String _label(TxType t) {
    switch (t) {
      case TxType.topup:
        return 'Пополнение';
      case TxType.purchase:
        return 'Покупка';
      case TxType.sale:
        return 'Продажа';
      case TxType.refund:
        return 'Возврат';
      case TxType.adminAdjustment:
        return 'Корректировка';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VorexColors.bgDeep,
      appBar: AppBar(title: const Text('История операций')),
      body: SafeArea(
        child: FutureBuilder(
          future: WalletService().history(user.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: VorexColors.accentBright));
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return const Center(child: Text('Пока нет операций', style: TextStyle(color: VorexColors.greyText)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final tx = items[i];
                final positive = tx.amount >= 0;
                return GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_label(tx.type), style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(tx.note, style: const TextStyle(color: VorexColors.greyText, fontSize: 12)),
                        ],
                      ),
                      Text(
                        '${positive ? '+' : ''}${tx.amount.toStringAsFixed(0)} ₽',
                        style: TextStyle(
                          color: positive ? VorexColors.success : VorexColors.danger,
                          fontWeight: FontWeight.w800,
                        ),
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
