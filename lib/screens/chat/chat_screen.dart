import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/order.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final Order order;
  final String currentUserId;
  const ChatScreen({super.key, required this.order, required this.currentUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _chatService = ChatService();
  List<ChatMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final msgs = await _chatService.history(widget.order.id);
    if (mounted) setState(() {
      _messages = msgs;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _chatService.send(orderId: widget.order.id, senderId: widget.currentUserId, text: text);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VorexColors.bgDeep,
      appBar: AppBar(title: const Text('Чат по сделке')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: VorexColors.accentBright))
                  : _messages.isEmpty
                      ? const Center(child: Text('Нет сообщений. Начните диалог!', style: TextStyle(color: VorexColors.greyText)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length,
                          itemBuilder: (context, i) {
                            final m = _messages[i];
                            final mine = m.senderId == widget.currentUserId;
                            return Align(
                              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                                decoration: BoxDecoration(
                                  color: mine ? VorexColors.accent : VorexColors.bgPanel,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(m.text, style: const TextStyle(color: VorexColors.white)),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(hintText: 'Сообщение...'),
                      style: const TextStyle(color: VorexColors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, color: VorexColors.accentBright),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
