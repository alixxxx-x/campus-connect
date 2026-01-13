import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/messaging_service.dart';

class AdminChatUser {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final String? profilePicture;

  AdminChatUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.profilePicture,
  });

  factory AdminChatUser.fromJson(Map<String, dynamic> json) {
    return AdminChatUser(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'STUDENT',
      profilePicture: json['profile_picture'],
    );
  }
}

class AdminChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  AdminChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory AdminChatMessage.fromJson(Map<String, dynamic> json) {
    return AdminChatMessage(
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

class AdminConversation {
  final AdminChatUser otherUser;
  final AdminChatMessage lastMessage;

  AdminConversation({required this.otherUser, required this.lastMessage});
}

final adminMessagingServiceProvider = Provider(
  (ref) => AdminMessagingService(),
);

final adminProfileProvider = StateProvider<AdminProfile?>((ref) => null);

class AdminProfile {
  final int id;
  final String username;
  final String fullName;

  AdminProfile({
    required this.id,
    required this.username,
    required this.fullName,
  });
}

final adminConversationsProvider = FutureProvider<List<AdminConversation>>((
  ref,
) async {
  final service = ref.read(adminMessagingServiceProvider);
  final profile = ref.watch(adminProfileProvider);
  if (profile == null) return [];

  final List<dynamic> messagesJson = await service.getConversations();
  final messages = messagesJson
      .map((m) => AdminChatMessage.fromJson(m))
      .toList();

  final Map<int, AdminChatMessage> latestMessages = {};
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
    return AdminConversation(
      otherUser: AdminChatUser(
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

final adminChatHistoryProvider =
    FutureProvider.family<List<AdminChatMessage>, int>((
      ref,
      otherUserId,
    ) async {
      final service = ref.read(adminMessagingServiceProvider);
      final json = await service.getMessagesWithUser(otherUserId);
      return json.map((m) => AdminChatMessage.fromJson(m)).toList();
    });

final adminUserSearchProvider =
    FutureProvider.family<List<AdminChatUser>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final service = ref.read(adminMessagingServiceProvider);
      final json = await service.searchUsers(query);
      return json.map((u) => AdminChatUser.fromJson(u)).toList();
    });
