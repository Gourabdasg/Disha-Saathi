import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  bool _isLoading = true;
  List<ChatSessionItem> _sessions = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    final state = context.read<AppState>();
    final lookupKey = state.mobile.isNotEmpty ? state.mobile : state.email.trim().toLowerCase();
    if (lookupKey.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final list = await ApiService.fetchChatSessions(lookupKey);
      if (mounted) {
        setState(() {
          _sessions = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    final state = context.read<AppState>();
    final lookupKey = state.mobile.isNotEmpty ? state.mobile : state.email.trim().toLowerCase();
    await ApiService.deleteChatSession(lookupKey, sessionId);
    setState(() {
      _sessions.removeWhere((s) => s.sessionId == sessionId);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat session deleted'), duration: Duration(seconds: 2)),
      );
    }
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return 'Today · ${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
      }
      return '${dt.day}/${dt.month}/${dt.year} · ${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';
    } catch (_) {
      return 'Saved Session';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Chat History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
            : _sessions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.forum_outlined, size: 48, color: AppColors.teal),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Saved Conversations',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.navy),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start a new chat to begin career guidance and NSQF training assessment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text('Start New Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              state.startNewChatSession();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sessions.length,
                    itemBuilder: (context, idx) {
                      final session = _sessions[idx];
                      final isActive = session.sessionId == state.activeSessionId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? AppColors.teal : const Color(0xFFE2E8F0),
                            width: isActive ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: CircleAvatar(
                            backgroundColor: isActive ? AppColors.teal : const Color(0xFFEBF3FF),
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: isActive ? Colors.white : AppColors.navy,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  session.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.navy),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.teal,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                session.lastMessage,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDate(session.updatedAt),
                                style: const TextStyle(fontSize: 11, color: AppColors.navy, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Conversation?'),
                                  content: const Text('Are you sure you want to delete this chat session?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteSession(session.sessionId);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          onTap: () async {
                            await state.loadChatSession(session.sessionId);
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
