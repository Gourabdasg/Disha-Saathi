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
import 'chat_history_screen.dart';
import 'training_screen.dart';

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
          _scrollController.position.maxScrollExtent + 250,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 250,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  /// Requirements 15 & 16 & 17: Multilingual Text-to-Speech playback
  Future<void> _playTtsForMessage(int index, String text) async {
    if (_playingMessageIndex == index) {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _playingMessageIndex = null;
          _isLoadingTts = false;
        });
      }
      return;
    }

    final langCode = context.read<AppState>().selectedLanguage.code;

    // Stop any previously playing audio before starting new playback
    await _audioPlayer.stop();

    if (!mounted) return;

    setState(() {
      _isLoadingTts = true;
      _playingMessageIndex = index;
    });

    try {
      final audioBase64 = await ApiService.textToSpeech(text, langCode);
      if (audioBase64 != null && audioBase64.isNotEmpty) {
        final bytes = base64Decode(audioBase64);
        await _audioPlayer.play(BytesSource(bytes));
        if (mounted) {
          setState(() {
            _isLoadingTts = false;
          });
        }
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
            content: Text('Unable to play audio. Please check your connection and try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showClearConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Messages?'),
        content: const Text('Clear messages in this current chat session? This will not delete your saved profile or previous chat history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppState>().clearChat();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
                        width: 38,
                        height: 38,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(19),
                          child: Image.asset('assets/app_icon_512.png', fit: BoxFit.cover),
                        ),
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
                          if (val == 'new_chat') {
                            context.read<AppState>().startNewChatSession();
                          } else if (val == 'history') {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
                            );
                          } else if (val == 'clear') {
                            _showClearConfirmationDialog(context);
                          } else if (val == 'restart') {
                            context.read<AppState>().restartChat();
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'new_chat',
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.navy),
                                SizedBox(width: 8),
                                Text('New Chat', style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'history',
                            child: Row(
                              children: [
                                Icon(Icons.history_rounded, size: 18, color: AppColors.teal),
                                SizedBox(width: 8),
                                Text('Chat History', style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: [
                                Icon(Icons.cleaning_services_rounded, size: 18, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Clear Messages', style: TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'restart',
                            child: Row(
                              children: [
                                Icon(Icons.restart_alt_rounded, size: 18, color: AppColors.orange),
                                SizedBox(width: 8),
                                Text('Restart Assessment', style: TextStyle(fontWeight: FontWeight.w600)),
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

            // Messages List with Bot Message Box (Matching Reference Image)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final isBot = m.isBot;
                  final isPlaying = _playingMessageIndex == i;

                  if (isBot) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.88,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3FF), // Light blue container from reference image
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD0E2FF), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Circular Bot Icon Badge (Matching Reference Image)
                                Container(
                                  width: 32,
                                  height: 32,
                                  margin: const EdgeInsets.only(top: 2, right: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E65D6), // Deep rich blue
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.podcasts_rounded, // Radio/signal/podcast icon from reference image
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),

                                // Bot Message Content (Styled text & NSQF Cards)
                                Expanded(
                                  child: _buildBotMessageContent(context, m.text),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Read Aloud Button (Bottom Right inside Bot Box - Matching Reference Image)
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () => _playTtsForMessage(i, m.text),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFD0E2FF), width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isLoadingTts && isPlaying)
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E65D6)),
                                        )
                                      else
                                        Icon(
                                          isPlaying ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                                          size: 16,
                                          color: isPlaying ? AppColors.orange : const Color(0xFF1E65D6),
                                        ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isPlaying ? 'Stop' : 'Read Aloud',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: isPlaying ? AppColors.orange : const Color(0xFF1E65D6),
                                        ),
                                      ),
                                      if (!isPlaying) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.campaign_rounded,
                                          size: 14,
                                          color: Color(0xFF1E65D6),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // User Message Bubble
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E65D6), // Rich deep blue
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: SelectableText(
                        m.text,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.35,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
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

class ParsedNsqfCourse {
  final String title;
  final String level;
  final String duration;
  final String sector;
  final String courseCode;
  final String awardingBody;
  final String careerPathway;
  final String matchScore;

  ParsedNsqfCourse({
    required this.title,
    required this.level,
    required this.duration,
    required this.sector,
    required this.courseCode,
    required this.awardingBody,
    required this.careerPathway,
    required this.matchScore,
  });
}

class ParsedBotMessage {
  final String headerText;
  final List<ParsedNsqfCourse> courses;
  final String footerText;

  ParsedBotMessage({
    required this.headerText,
    required this.courses,
    required this.footerText,
  });
}

ParsedBotMessage _parseBotMessage(String text) {
  final cleanText = text.replaceAll('**', '');

  if (!cleanText.contains('Course Code:') && !cleanText.contains('Match Score:')) {
    return ParsedBotMessage(
      headerText: cleanText.trim(),
      courses: [],
      footerText: '',
    );
  }

  String mainBody = cleanText;
  String footerText = '';

  if (cleanText.contains('Why this is recommended')) {
    final parts = cleanText.split(RegExp(r'💡\s*Why this is recommended:?|Why this is recommended:?'));
    mainBody = parts[0];
    if (parts.length > 1) {
      footerText = '💡 Why this is recommended:\n${parts[1].trim()}';
    }
  }

  String headerText = '';
  final courseStartIndex = mainBody.indexOf(RegExp(r'\n1\.\s+|\n1\s+'));
  if (courseStartIndex != -1) {
    headerText = mainBody.substring(0, courseStartIndex).trim();
    mainBody = mainBody.substring(courseStartIndex);
  } else if (mainBody.contains('Course Code:')) {
    final firstCode = mainBody.indexOf('Course Code:');
    final lineStart = mainBody.lastIndexOf('\n', firstCode);
    if (lineStart != -1) {
      headerText = mainBody.substring(0, lineStart).trim();
      mainBody = mainBody.substring(lineStart);
    }
  }

  final courseBlocks = mainBody.split(RegExp(r'\n(?=\d+[\.\)]\s+)'));
  List<ParsedNsqfCourse> courses = [];

  for (final block in courseBlocks) {
    if (!block.contains('Course Code:') && !block.contains('Match Score:')) continue;

    String title = '';
    String level = '';
    String duration = '';
    String sector = '';
    String courseCode = '';
    String awardingBody = '';
    String careerPathway = '';
    String matchScore = '';

    final lines = block.split('\n');
    for (var line in lines) {
      final trimmed = line.trim().replaceAll(RegExp(r'^[•\-\*\d\.\)\s]+'), '');

      if (trimmed.contains('Level') && (trimmed.contains('Hours') || trimmed.contains('Duration'))) {
        final levelMatch = RegExp(r'\((Level\s*\d+)\s*·?\s*(.*?)\)').firstMatch(trimmed);
        if (levelMatch != null) {
          title = trimmed.substring(0, levelMatch.start).trim();
          level = levelMatch.group(1) ?? '';
          duration = levelMatch.group(2) ?? '';
        } else {
          title = trimmed;
        }
      } else if (title.isEmpty && trimmed.isNotEmpty && !trimmed.contains(':')) {
        title = trimmed;
      }

      if (trimmed.startsWith('Sector:')) {
        sector = trimmed.replaceFirst('Sector:', '').trim();
      } else if (trimmed.startsWith('Course Code:')) {
        courseCode = trimmed.replaceFirst('Course Code:', '').trim();
      } else if (trimmed.startsWith('Awarding Body:')) {
        awardingBody = trimmed.replaceFirst('Awarding Body:', '').trim();
      } else if (trimmed.startsWith('Career Pathway:')) {
        careerPathway = trimmed.replaceFirst('Career Pathway:', '').trim();
      } else if (trimmed.startsWith('Match Score:')) {
        matchScore = trimmed.replaceFirst('Match Score:', '').trim();
      }
    }

    if (title.isNotEmpty) {
      courses.add(ParsedNsqfCourse(
        title: title,
        level: level.isNotEmpty ? level : 'Level 3',
        duration: duration.isNotEmpty ? duration : '300 Hours',
        sector: sector.isNotEmpty ? sector : 'Skill Development',
        courseCode: courseCode,
        awardingBody: awardingBody,
        careerPathway: careerPathway,
        matchScore: matchScore.isNotEmpty ? matchScore : '85%',
      ));
    }
  }

  return ParsedBotMessage(
    headerText: headerText,
    courses: courses,
    footerText: footerText,
  );
}

Widget _buildBotMessageContent(BuildContext context, String text) {
  final parsed = _parseBotMessage(text);

  if (parsed.courses.isEmpty) {
    return SelectableText(
      parsed.headerText,
      style: const TextStyle(
        fontSize: 14.5,
        height: 1.45,
        color: Color(0xFF1A2138),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (parsed.headerText.isNotEmpty) ...[
        SelectableText(
          parsed.headerText,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.45,
            color: Color(0xFF1A2138),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
      ],

      // Render Individual Course Cards
      ...parsed.courses.map((c) => _buildNsqfCard(context, c)),

      if (parsed.footerText.isNotEmpty) ...[
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
          ),
          child: Text(
            parsed.footerText,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ],
  );
}

Widget _buildNsqfCard(BuildContext context, ParsedNsqfCourse course) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header: 🎓 NSQF TRAINING Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text('🎓', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 5),
                  Text('NSQF TRAINING', style: TextStyle(color: AppColors.navy, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
                ],
              ),
            ),
            if (course.matchScore.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ),
                child: Text('⭐ ${course.matchScore} Match', style: const TextStyle(color: Color(0xFFB45309), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Course Title
        Text(
          course.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.35),
        ),

        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 12),

        // Key-Value Grid Rows (Matching Screenshot 1)
        if (course.level.isNotEmpty) _courseDetailRow('NSQF Level', course.level),
        if (course.duration.isNotEmpty) _courseDetailRow('Duration', course.duration),
        if (course.sector.isNotEmpty) _courseDetailRow('Sector', course.sector),
        if (course.courseCode.isNotEmpty) _courseDetailRow('Course Code', course.courseCode),

        if (course.awardingBody.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Awarding Body', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            course.awardingBody,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.3),
          ),
        ],

        if (course.careerPathway.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Career Pathway', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            course.careerPathway,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.3),
          ),
        ],

        const SizedBox(height: 16),

        // Find Training Button
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrainingScreen()),
              );
            },
            icon: const Icon(Icons.location_searching_rounded, size: 16, color: Colors.white),
            label: const Text('Find Training Near You →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _courseDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
        ),
      ],
    ),
  );
}
