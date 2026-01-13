import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/messaging_service.dart';
import 'student_providers.dart';

class ChatUser {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final String? profilePicture;

  ChatUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.profilePicture,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'STUDENT',
      profilePicture: json['profile_picture'],
    );
  }
}

class ChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender'],
      senderName: json['sender_name'] ?? '',
      receiverId: json['receiver'],
      receiverName: json['receiver_name'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
    );
  }
}

class Conversation {
  final ChatUser otherUser;
  final ChatMessage lastMessage;

  Conversation({required this.otherUser, required this.lastMessage});
}

final messagingServiceProvider = Provider((ref) => MessagingService());

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final service = ref.read(messagingServiceProvider);
  final profile = ref.watch(studentProfileProvider);
  if (profile == null) return [];

  final List<dynamic> messagesJson = await service.getConversations();
  final messages = messagesJson.map((m) => ChatMessage.fromJson(m)).toList();

  final Map<int, ChatMessage> latestMessages = {};
  final Map<int, String> names = {};

  for (var msg in messages) {
    bool isMeSender = msg.senderId == profile.id;
    int otherId = isMeSender ? msg.receiverId : msg.senderId;
    String otherName = isMeSender ? msg.receiverName : msg.senderName;

    if (!latestMessages.containsKey(otherId) ||
        msg.timestamp.isAfter(latestMessages[otherId]!.timestamp)) {
      latestMessages[otherId] = msg;
      names[otherId] = otherName;
    }
  }

  final conversationList = latestMessages.entries.map((e) {
    return Conversation(
      otherUser: ChatUser(
        id: e.key,
        username: '',
        fullName: names[e.key]!,
        role: '',
      ),
      lastMessage: e.value,
    );
  }).toList();

  conversationList.sort(
    (a, b) => b.lastMessage.timestamp.compareTo(a.lastMessage.timestamp),
  );
  return conversationList;
});

final chatHistoryProvider = FutureProvider.family<List<ChatMessage>, int>((
  ref,
  otherUserId,
) async {
  final service = ref.read(messagingServiceProvider);
  final json = await service.getMessagesWithUser(otherUserId);
  return json.map((m) => ChatMessage.fromJson(m)).toList();
});

final userSearchProvider = FutureProvider.family<List<ChatUser>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];
  final service = ref.read(messagingServiceProvider);
  final json = await service.searchUsers(query);
  return json.map((u) => ChatUser.fromJson(u)).toList();
});
