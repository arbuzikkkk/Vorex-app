import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_card.dart';
import '../main_nav_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  // Secret admin gate: tap the logo 5 times to reveal an admin login link.
  int _logoTaps = 0;
  bool _adminUnlocked = false;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final user = await AuthService().login(_username.text.trim(), _password.text);
    setState(() => _loading = false);
    if (user == null) {
      setState(() => _error = 'Неверный логин или пароль, либо аккаунт заблокирован');
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VorexColors.bgDeep,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    _logoTaps++;
                    if (_logoTaps >= 5) {
                      setState(() => _adminUnlocked = true);
                    }
                  },
                  child: const Text(
                    'VOREX',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 4),
                  ),
                ),
                const SizedBox(height: 32),
                GlassCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _username,
                        decoration: const InputDecoration(hintText: 'Логин'),
                        style: const TextStyle(color: VorexColors.white),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(hintText: 'Пароль'),
                        style: const TextStyle(color: VorexColors.white),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: const TextStyle(color: VorexColors.danger, fontSize: 13)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  height: 18, width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Войти'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Нет аккаунта? Зарегистрироваться',
                      style: TextStyle(color: VorexColors.greyText)),
                ),
                if (_adminUnlocked)
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/admin-login'),
                    child: const Text('Вход для администратора',
                        style: TextStyle(color: VorexColors.accentBright, fontSize: 12)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
