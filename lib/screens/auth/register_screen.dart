import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_card.dart';
import '../main_nav_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    if (_username.text.trim().length < 3) {
      setState(() => _error = 'Логин минимум 3 символа');
      return;
    }
    if (_password.text.length < 4) {
      setState(() => _error = 'Пароль минимум 4 символа');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final user = await AuthService().register(_username.text.trim(), _password.text);
    setState(() => _loading = false);
    if (user == null) {
      setState(() => _error = 'Такой логин уже занят');
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VorexColors.bgDeep,
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassCard(
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
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Создать аккаунт'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
