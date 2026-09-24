import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../models/transaction.dart';
import '../../services/wallet_service.dart';
import '../../widgets/glass_card.dart';

/// Top-up flow with mocked payment confirmation — swap _confirmPayment
/// for a real gateway callback once the app is wired to a backend.
class TopUpScreen extends StatefulWidget {
  final AppUser user;
  const TopUpScreen({super.key, required this.user});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final _amount = TextEditingController();
  bool _processing = false;

  Future<void> _confirmPayment() async {
    final amount = double.tryParse(_amount.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 900)); // simulated processing
    await WalletService().applyTransaction(
      userId: widget.user.id,
      type: TxType.topup,
      amount: amount,
      note: 'Пополнение баланса',
    );
    if (!mounted) return;
    setState(() => _processing = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VorexColors.bgDeep,
      appBar: AppBar(title: const Text('Пополнение баланса')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GlassCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Сумма, ₽'),
                      style: const TextStyle(color: VorexColors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [500, 1000, 2000, 5000].map((v) {
                        return ActionChip(
                          label: Text('$v ₽'),
                          backgroundColor: VorexColors.bgPanel,
                          labelStyle: const TextStyle(color: VorexColors.white),
                          onPressed: () => setState(() => _amount.text = v.toString()),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _processing ? null : _confirmPayment,
                  child: _processing
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Пополнить'),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Платёжный шлюз симулирован. Подключите реальный провайдер (ЮKassa, Stripe и т.д.) в services/wallet_service.dart',
                textAlign: TextAlign.center,
                style: TextStyle(color: VorexColors.greyText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
