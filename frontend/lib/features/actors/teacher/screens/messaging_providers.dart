import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/messaging_service.dart';
import 'teacher_providers.dart';

class TeacherChatUser {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final String? profilePicture;

  TeacherChatUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.profilePicture,
  });

  factory TeacherChatUser.fromJson(Map<String, dynamic> json) {
    return TeacherChatUser(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'STUDENT',
      profilePicture: json['profile_picture'],
    );
  }
}

class TeacherChatMessage {
  final int id;
  final int senderId;
  final String senderName;
  final int receiverId;
  final String receiverName;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  TeacherChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory TeacherChatMessage.fromJson(Map<String, dynamic> json) {
    return TeacherChatMessage(
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

class TeacherConversation {
  final TeacherChatUser otherUser;
  final TeacherChatMessage lastMessage;

  TeacherConversation({required this.otherUser, required this.lastMessage});
}

final teacherMessagingServiceProvider = Provider(
  (ref) => TeacherMessagingService(),
);

final teacherConversationsProvider = FutureProvider<List<TeacherConversation>>((
  ref,
) async {
  final service = ref.read(teacherMessagingServiceProvider);
  final profile = ref.watch(teacherProfileProvider);
  if (profile == null) return [];

  final List<dynamic> messagesJson = await service.getConversations();
  final messages = messagesJson
      .map((m) => TeacherChatMessage.fromJson(m))
      .toList();

  final Map<int, TeacherChatMessage> latestMessages = {};
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
    return TeacherConversation(
      otherUser: TeacherChatUser(
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

final teacherChatHistoryProvider =
    FutureProvider.family<List<TeacherChatMessage>, int>((
      ref,
      otherUserId,
    ) async {
      final service = ref.read(teacherMessagingServiceProvider);
      final json = await service.getMessagesWithUser(otherUserId);
      return json.map((m) => TeacherChatMessage.fromJson(m)).toList();
    });

final teacherUserSearchProvider =
    FutureProvider.family<List<TeacherChatUser>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final service = ref.read(teacherMessagingServiceProvider);
      final json = await service.searchUsers(query);
      return json.map((u) => TeacherChatUser.fromJson(u)).toList();
    });
