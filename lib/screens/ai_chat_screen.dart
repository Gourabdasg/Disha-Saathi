import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isListening = false;
  bool _speechEnabled = false;
  String _lastWords = '';

  int? _playingMessageIndex;
  bool _isSynthesizingTts = false;

  final List<String> _sampleVoicePrompts = const [
    'मैं खेती का काम करता हूँ और सिलाई भी जानता हूँ।',
    'I am 10th pass and know basic computer operations and typing.',
    'मुझे बिजली की वायरिंग का काम आता है और जॉब चाहिए।',
    'I want a full-time tailoring job in Kolkata.',
    'मैं ड्राइविंग जानता हूँ और कमर्शियल ड्राइवर बनना चाहता हूँ।',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playingMessageIndex = null;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadChatHistory().then((_) => _scrollToBottom());
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Initializes device microphone speech-to-text engine.
  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
      );
    } catch (_) {
      _speechEnabled = false;
    }
  }

  /// Toggles live microphone listening to transcribe spoken words into the text box.
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final langCode = context.read<AppState>().selectedLanguage.code;
    String localeId = 'hi_IN';
    if (langCode == 'en') localeId = 'en_US';
    if (langCode == 'bn') localeId = 'bn_IN';
    if (langCode == 'mr') localeId = 'mr_IN';
    if (langCode == 'te') localeId = 'te_IN';

    _speechEnabled = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );

    if (_speechEnabled && mounted) {
      setState(() {
        _isListening = true;
      });

      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          localeId: localeId,
        ),
        onResult: (result) {
          if (mounted) {
            setState(() {
              _lastWords = result.recognizedWords;
              if (_lastWords.isNotEmpty) {
                _textController.text = _lastWords;
                _textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _textController.text.length),
                );
              }
            });
          }
        },
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Live speech recognition unavailable on emulator. Loaded sample voice prompt.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      _useSampleVoicePrompt();
    }
  }

  void _useSampleVoicePrompt([String? customPrompt]) {
    final prompt = customPrompt ?? _sampleVoicePrompts[0];
    setState(() {
      _textController.text = prompt;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    });
  }

  Future<void> _send() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    if (!mounted) return;
    await context.read<AppState>().sendChatMessage(text);
    if (mounted) _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  /// Requirements 15 & 16 & 17: NVIDIA Text-to-Speech playback via Backend Proxy
  Future<void> _playTtsForMessage(int index, String text) async {
    final langCode = context.read<AppState>().selectedLanguage.code;

    if (_playingMessageIndex == index) {
      await _audioPlayer.stop();
      setState(() => _playingMessageIndex = null);
      return;
    }

    await _audioPlayer.stop();
    setState(() {
      _playingMessageIndex = index;
      _isSynthesizingTts = true;
    });

    try {
      final audioBase64 = await ApiService.textToSpeech(text, langCode);
      setState(() => _isSynthesizingTts = false);

      if (audioBase64 != null && audioBase64.isNotEmpty) {
        final bytes = base64Decode(audioBase64);
        await _audioPlayer.play(BytesSource(bytes));
      } else {
        setState(() => _playingMessageIndex = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reading message aloud...'), duration: Duration(seconds: 2)),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isSynthesizingTts = false;
        _playingMessageIndex = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio speech playback error.'), duration: Duration(seconds: 2)),
        );
      }
    }
  }

  void _confirmRestartChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restart Conversation?'),
        content: const Text('Are you sure you want to restart your current AI conversation flow?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppState>().restartChat();
            },
            child: const Text('Restart', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Chat History?'),
        content: const Text('Are you sure you want to permanently delete all messages in this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppState>().clearChat();
            },
            child: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Requirement 10: Message Edit & Resend / Delete Options Modal
  void _showMessageOptionsModal(int index, String text, bool isBot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              Text(
                isBot ? 'Bot Message Options' : 'User Message Options',
                style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),
              if (isBot) ...[
                ListTile(
                  leading: const Icon(Icons.volume_up_rounded, color: AppColors.navy),
                  title: const Text('Read Aloud (TTS)', style: TextStyle(color: AppColors.textDark)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _playTtsForMessage(index, text);
                  },
                ),
                const Divider(height: 1),
              ],
              if (!isBot) ...[
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: AppColors.navy),
                  title: const Text('Edit & Resend', style: TextStyle(color: AppColors.textDark)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _textController.text = text;
                      _textController.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
                    });
                    context.read<AppState>().editAndResendMessage(index, text);
                  },
                ),
                const Divider(height: 1),
              ],
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                title: const Text('Delete Message', style: TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<AppState>().deleteChatMessage(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoiceOptionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Voice Prompts Selector',
                    style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.record_voice_over_rounded, color: AppColors.navy),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Select a voice sample to populate into your text box:',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ..._sampleVoicePrompts.map((p) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.mic, color: AppColors.navy, size: 20),
                    title: Text(p, style: const TextStyle(color: AppColors.textDark, fontSize: 13.5)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _useSampleVoicePrompt(p);
                    },
                  )),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final messages = state.chatMessages;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with "Restart" & Three-Dot Menu (⋯)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient)),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('AI SKILL ASSISTANT',
                                style: TextStyle(color: AppColors.tealLight, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
                            Text('Livelihood Assessment', style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),

                      TextButton.icon(
                        onPressed: _confirmRestartChat,
                        icon: const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 18),
                        label: const Text('Restart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),

                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        onSelected: (val) {
                          if (val == 'new') {
                            state.startNewChat();
                          } else if (val == 'restart') {
                            _confirmRestartChat();
                          } else if (val == 'clear') {
                            _confirmClearChat();
                          } else if (val == 'history') {
                            state.loadChatHistory();
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'new',
                            child: Row(
                              children: [
                                Icon(Icons.add_rounded, color: AppColors.navy, size: 18),
                                SizedBox(width: 10),
                                Text('New Chat', style: TextStyle(color: AppColors.textDark, fontSize: 13.5)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'restart',
                            child: Row(
                              children: [
                                Icon(Icons.restart_alt_rounded, color: AppColors.navy, size: 18),
                                SizedBox(width: 10),
                                Text('Restart Conversation', style: TextStyle(color: AppColors.textDark, fontSize: 13.5)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'history',
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded, color: AppColors.navy, size: 18),
                                SizedBox(width: 10),
                                Text('Chat History', style: TextStyle(color: AppColors.textDark, fontSize: 13.5)),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(height: 1),
                          const PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: [
                                Icon(Icons.delete_sweep_rounded, color: AppColors.danger, size: 18),
                                SizedBox(width: 10),
                                Text('Clear Chat', style: TextStyle(color: AppColors.danger, fontSize: 13.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Livelihood Assessment', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('60% Complete', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(value: 0.6, minHeight: 6, backgroundColor: Colors.white24, color: AppColors.tealLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Messages List with Speaker Icon 🔊 for TTS (Requirements 15, 16, 17)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final isPlayingThis = _playingMessageIndex == i;

                  return GestureDetector(
                    onLongPress: () => _showMessageOptionsModal(i, m.text, m.isBot),
                    child: Align(
                      alignment: m.isBot ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                        decoration: BoxDecoration(
                          color: m.isBot ? const Color(0xFFE8F1FD) : AppColors.navy,
                          borderRadius: BorderRadius.circular(16),
                          border: m.isBot ? Border.all(color: const Color(0xFFD0E1FD), width: 1) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (m.isBot)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8, top: 2),
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: AppColors.navy,
                                      child: Icon(Icons.podcasts, size: 12, color: Colors.white),
                                    ),
                                  ),
                                Flexible(
                                  child: Text(
                                    m.text,
                                    style: TextStyle(
                                      color: m.isBot ? AppColors.textDark : Colors.white,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Requirements 16 & 17: Speaker Icon 🔊 for AI Message Text-To-Speech
                            if (m.isBot) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () => _playTtsForMessage(i, m.text),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPlayingThis ? AppColors.navy : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isPlayingThis && _isSynthesizingTts)
                                            const SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.navy),
                                            )
                                          else
                                            Icon(
                                              isPlayingThis ? Icons.pause_circle_filled_rounded : Icons.volume_up_rounded,
                                              color: isPlayingThis ? Colors.white : AppColors.navy,
                                              size: 16,
                                            ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isPlayingThis ? 'Playing…' : 'Read Aloud 🔊',
                                            style: TextStyle(
                                              color: isPlayingThis ? Colors.white : AppColors.navy,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Text Input & Voice Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(color: AppColors.textDark),
                            decoration: const InputDecoration(
                              hintText: 'Type your response...',
                              hintStyle: TextStyle(color: AppColors.textMuted),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: _send,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Voice Action Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roundIcon(Icons.list_alt_rounded, _showVoiceOptionsModal),
                      const SizedBox(width: 22),
                      InkWell(
                        onTap: _toggleListening,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: AppColors.buttonGradient),
                            boxShadow: _isListening
                                ? [BoxShadow(color: AppColors.navy.withOpacity(0.5), blurRadius: 28, spreadRadius: 8)]
                                : [],
                          ),
                          child: Icon(_isListening ? Icons.graphic_eq_rounded : Icons.mic_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 22),
                      _roundIcon(Icons.backspace_outlined, () {
                        _textController.clear();
                        if (_isListening) {
                          _speech.stop();
                          setState(() => _isListening = false);
                        }
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isListening ? 'Listening live... Speak now!' : 'Tap mic to speak or select a voice prompt',
                    style: TextStyle(
                      color: _isListening ? AppColors.navy : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, color: AppColors.navy, size: 20),
      ),
    );
  }
}
