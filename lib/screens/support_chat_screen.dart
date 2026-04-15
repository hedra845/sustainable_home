import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Stream<List<Map<String, dynamic>>> _messagesStream;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // استماع للرسائل الخاصة بالمستخدم الحالي فقط في الوقت الفعلي
    _messagesStream = Supabase.instance.client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('user_id', _currentUserId ?? '')
        .order('created_at', ascending: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      await Supabase.instance.client.from('support_messages').insert({
        'content': text,
        'is_admin': false,
        'user_id': _currentUserId,
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Support Chat'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'How can we help you today?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isAdmin = msg['is_admin'] == true;

                    return Align(
                      alignment:
                          isAdmin
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isAdmin
                                  ? colorScheme.surfaceContainerHighest
                                  : colorScheme.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isAdmin ? 4 : 16),
                            bottomRight: Radius.circular(isAdmin ? 16 : 4),
                          ),
                        ),
                        child: Text(
                          msg['content'] ?? '',
                          style: TextStyle(
                            color:
                                isAdmin
                                    ? colorScheme.onSurface
                                    : colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSending ? null : _sendMessage,
                  icon:
                      _isSending
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
