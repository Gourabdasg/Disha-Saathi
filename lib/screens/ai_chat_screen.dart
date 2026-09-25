import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _scrollController = ScrollController();
  final _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  int? _playingMessageIndex;
  bool _isLoadingTts = false;

  final List<String> _sampleVoicePrompts = [
    'I want to learn tailoring and garment design in West Bengal.',
    'Where can I apply for organic farming training near my district?',
    'Show me computer and data entry courses with NSQF certification.',
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
    if (langCode == 'ta') localeId = 'ta_IN';
    if (langCode == 'gu') localeId = 'gu_IN';
    if (langCode == 'kn') localeId = 'kn_IN';
    if (langCode == 'ml') localeId = 'ml_IN';
    if (langCode == 'pa') localeId = 'pa_IN';
    if (langCode == 'ur') localeId = 'ur_IN';

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
    _scrollToBottom();
    await context.read<AppState>().sendChatMessage(text);
    if (mounted) _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  /// Requirements 15 & 16 & 17: NVIDIA Text-to-Speech playback via Backend Proxy
  Future<void> _playTtsForMessage(int index, String text) async {
    if (_playingMessageIndex == index) {
      await _audioPlayer.stop();
      setState(() => _playingMessageIndex = null);
      return;
    }

    setState(() {
      _isLoadingTts = true;
      _playingMessageIndex = index;
    });

    final langCode = context.read<AppState>().selectedLanguage.code;

    try {
      final audioBase64 = await ApiService.textToSpeech(text, langCode);
      if (audioBase64 != null && audioBase64.isNotEmpty) {
        final bytes = base64Decode(audioBase64);
        await _audioPlayer.stop();
        await _audioPlayer.play(BytesSource(bytes));
        if (mounted) setState(() => _isLoadingTts = false);
      } else {
        throw Exception('TTS Audio unavailable');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingTts = false;
          _playingMessageIndex = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio playback unavailable in offline mode.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final messages = state.chatMessages;
    final activeLang = state.selectedLanguage;
    final profile = state.profile;

    final completionPercent = profile.profileCompletionPercent;
    final double completionValue = (completionPercent / 100.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar Header with Multilingual Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('ai_chat_title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'Powered by NVIDIA AI · Multi-Language',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),

                      // Language Switcher Badge Button
                      InkWell(
                        onTap: () => _showLanguageSelector(context, state),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white38),
                          ),
                          child: Row(
                            children: [
                              Text(
                                activeLang.flagLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activeLang.nativeName,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              const Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      // Clear / Restart Conversation Button
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                        onSelected: (val) {
                          if (val == 'clear') {
                            context.read<AppState>().clearChat();
                          } else if (val == 'restart') {
                            context.read<AppState>().restartChat();
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: [
                                Icon(Icons.cleaning_services_rounded, size: 18, color: AppColors.navy),
                                SizedBox(width: 8),
                                Text('Clear Messages'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'restart',
                            child: Row(
                              children: [
                                Icon(Icons.restart_alt_rounded, size: 18, color: AppColors.orange),
                                SizedBox(width: 8),
                                Text('Restart Assessment'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Dynamic Progress Bar (Requirement 6)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Livelihood Assessment', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('$completionPercent% Complete', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: completionValue, minHeight: 6, backgroundColor: Colors.white24, color: AppColors.tealLight),
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
                  final isBot = m.isBot;
                  final isPlaying = _playingMessageIndex == i;

                  return Align(
                    alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isBot ? Colors.white : AppColors.navy,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isBot ? 0 : 16),
                          bottomRight: Radius.circular(isBot ? 16 : 0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isBot ? 'Disha Saathi Assistant' : 'You',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isBot ? AppColors.teal : Colors.white70,
                                ),
                              ),

                              // Read Aloud / Speaker Button for Bot Messages (Requirement 17)
                              if (isBot)
                                InkWell(
                                  onTap: () => _playTtsForMessage(i, m.text),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: _isLoadingTts && isPlaying
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
                                          )
                                        : Icon(
                                            isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                                            size: 20,
                                            color: isPlaying ? AppColors.orange : AppColors.teal,
                                          ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Message Text Content
                          SelectableText(
                            m.text,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: isBot ? AppColors.navy : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Voice Speech Input & Text Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Suggested Voice Prompts Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _sampleVoicePrompts
                          .map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(right: 8, bottom: 6),
                              child: ActionChip(
                                label: Text(p, style: const TextStyle(fontSize: 11.5)),
                                backgroundColor: AppColors.bgLight,
                                onPressed: () => _useSampleVoicePrompt(p),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  Row(
                    children: [
                      // Voice Record Microphone Button
                      GestureDetector(
                        onTap: _toggleListening,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isListening ? AppColors.orange : AppColors.teal,
                            shape: BoxShape.circle,
                            boxShadow: _isListening
                                ? [
                                    BoxShadow(
                                      color: AppColors.orange.withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: Icon(
                            _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Message Input Box
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: _isListening
                                ? 'Listening... Speak now...'
                                : 'Type or speak in ${activeLang.nativeName}...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.bgLight,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Send Button
                      IconButton(
                        onPressed: _send,
                        icon: const Icon(Icons.send_rounded, color: AppColors.navy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.tr('select_language'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: AppLanguage.all.length,
                  itemBuilder: (context, idx) {
                    final lang = AppLanguage.all[idx];
                    final isSelected = state.selectedLanguage.code == lang.code;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? AppColors.teal : AppColors.bgLight,
                        child: Text(
                          lang.flagLabel,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.navy,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(lang.nativeName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text(lang.englishName, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.teal) : null,
                      onTap: () {
                        state.setLanguage(lang);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
