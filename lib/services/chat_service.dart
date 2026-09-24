import 'package:uuid/uuid.dart';
import '../database/db_helper.dart';
import '../models/chat_message.dart';

class ChatService {
  static const _uuid = Uuid();

  Future<ChatMessage> send({required String orderId, required String senderId, required String text}) async {
    final msg = ChatMessage(
      id: _uuid.v4(),
      orderId: orderId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );
    final db = await DBHelper.instance.database;
    await db.insert('chat_messages', msg.toMap());
    return msg;
  }

  Future<List<ChatMessage>> history(String orderId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('chat_messages', where: 'orderId = ?', whereArgs: [orderId], orderBy: 'createdAt ASC');
    return rows.map((r) => ChatMessage.fromMap(r)).toList();
  }
}
