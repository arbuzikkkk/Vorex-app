import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_card.dart';
import '../auth/login_screen.dart';
import 'topup_screen.dart';
import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AppUser? user;
  final VoidCallback onUserChanged;
  const ProfileScreen({super.key, required this.user, required this.onUserChanged});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: VorexColors.accent,
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.username ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${user?.balance.toStringAsFixed(0) ?? 0} ₽',
                        style: const TextStyle(color: VorexColors.accentBright, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProfileTile(
            icon: Icons.add_card_rounded,
            title: 'Пополнить баланс',
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => TopUpScreen(user: user!)));
              onUserChanged();
            },
          ),
          _ProfileTile(
            icon: Icons.history_rounded,
            title: 'История операций',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => HistoryScreen(user: user!))),
          ),
          _ProfileTile(
            icon: Icons.notifications_none_rounded,
            title: 'Уведомления',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Push-уведомления подключаются после интеграции с backend')),
            ),
          ),
          const SizedBox(height: 12),
          _ProfileTile(
            icon: Icons.logout_rounded,
            title: 'Выйти',
            danger: true,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;
  const _ProfileTile({required this.icon, required this.title, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: danger ? VorexColors.danger : VorexColors.accentBright),
            const SizedBox(width: 14),
            Text(title, style: TextStyle(color: danger ? VorexColors.danger : VorexColors.white, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: VorexColors.greyText),
          ],
        ),
      ),
    );
  }
}
