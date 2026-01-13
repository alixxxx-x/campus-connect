import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'messaging_providers.dart';
import 'admin_chat_screen.dart';
import 'admin_style.dart';
import '../../../../shared/providers/auth_provider.dart';

class AdminMessagesTab extends ConsumerStatefulWidget {
  const AdminMessagesTab({super.key});

  @override
  ConsumerState<AdminMessagesTab> createState() => _AdminMessagesTabState();
}

class _AdminMessagesTabState extends ConsumerState<AdminMessagesTab> {
  @override
  void initState() {
    super.initState();
    // Initialize admin profile from auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider);
      if (user != null) {
        ref.read(adminProfileProvider.notifier).state = AdminProfile(
          id: int.parse(user.id),
          username: user.email.split('@')[0], // Use email prefix as username
          fullName: user.name,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(adminConversationsProvider);

    return Scaffold(
      backgroundColor: AdminStyle.bg,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminConversationsProvider.future),
        child: conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return _buildEmptyState(context, ref);
            }
            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: conversations.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _buildConversationTile(context, conversation);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearch(context, ref),
        backgroundColor: AdminStyle.primary,
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Start a conversation with a user'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showSearch(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminStyle.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Search People'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    AdminConversation conversation,
  ) {
    final lastMsg = conversation.lastMessage;
    final otherUser = conversation.otherUser;

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AdminStyle.primary.withOpacity(0.1),
        child: Text(
          otherUser.fullName.isNotEmpty
              ? otherUser.fullName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: AdminStyle.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        otherUser.fullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        lastMsg.content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(lastMsg.timestamp),
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
          if (!lastMsg.isRead && lastMsg.receiverId != otherUser.id)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AdminStyle.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminChatScreen(otherUser: otherUser),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays == 0) {
      return DateFormat.Hm().format(timestamp);
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(timestamp);
    } else {
      return DateFormat.yMd().format(timestamp);
    }
  }

  void _showSearch(BuildContext context, WidgetRef ref) {
    showSearch(context: context, delegate: AdminUserSearchDelegate(ref));
  }
}

class AdminUserSearchDelegate extends SearchDelegate {
  final WidgetRef ref;
  AdminUserSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchList();
  }

  Widget _buildSearchList() {
    if (query.length < 2) {
      return const Center(child: Text('Type at least 2 characters to search'));
    }
    final searchAsync = ref.watch(adminUserSearchProvider(query));

    return searchAsync.when(
      data: (users) {
        if (users.isEmpty) return const Center(child: Text('No users found'));
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : '?',
                ),
              ),
              title: Text(user.fullName),
              subtitle: Text(user.role),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminChatScreen(otherUser: user),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
