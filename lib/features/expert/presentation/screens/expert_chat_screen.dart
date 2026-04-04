import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';

class ExpertChatScreen extends StatefulWidget {
  const ExpertChatScreen({super.key});

  @override
  State<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

class _ExpertChatScreenState extends State<ExpertChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Hello Tendai! I\'m Dr. Chipo, your agronomist. How can I help you today?',
      isMe: false,
      sender: 'Dr. Chipo Nyathi',
      time: '9:00 AM',
    ),
    _ChatMessage(
      text: 'Hi Doctor. My maize leaves are turning yellow at the tips. What could be the problem?',
      isMe: true,
      sender: 'You',
      time: '9:02 AM',
    ),
    _ChatMessage(
      text: 'That could indicate nitrogen deficiency. A few questions:\n\n1. When did you last apply fertilizer?\n2. How much rain have you received recently?\n3. Is the yellowing starting from the lower leaves?',
      isMe: false,
      sender: 'Dr. Chipo Nyathi',
      time: '9:03 AM',
    ),
    _ChatMessage(
      text: 'Yes, it\'s starting from the lower leaves. I applied basal compound 3 weeks ago but haven\'t done top dressing yet.',
      isMe: true,
      sender: 'You',
      time: '9:05 AM',
    ),
    _ChatMessage(
      text: 'That confirms nitrogen deficiency. Here\'s my recommendation:\n\n🌿 Apply Ammonium Nitrate (AN) top dressing at 200kg/ha\n⏰ Do it within the next 3 days\n🌧️ Best if done before rain\n\nYour maize is at the right stage for top dressing. This should resolve the yellowing within 7-10 days.',
      isMe: false,
      sender: 'Dr. Chipo Nyathi',
      time: '9:07 AM',
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isMe: true,
        sender: 'You',
        time: 'Now',
      ));
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate AI Dr. Chipo typing back
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        String replyText = 'Thanks for the details. Given the current weather patterns in your region, I suggest monitoring the soil moisture before the next top dressing.';
        
        if (text.toLowerCase().contains('rain') || text.toLowerCase().contains('water')) {
          replyText = 'Since rain is expected, delay any chemical spraying by 24 hours so it isn\'t washed away.';
        } else if (text.toLowerCase().contains('pest') || text.toLowerCase().contains('bug')) {
          replyText = 'Please upload a clear photo of the pest or leaf damage so I can recommend the exact pesticide.';
        }

        _messages.add(_ChatMessage(
          text: replyText,
          isMe: false,
          sender: 'Dr. Chipo Nyathi',
          time: 'Now',
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.advisory.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'CN',
                  style: TextStyle(
                    color: AppColors.advisory,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Chipo Nyathi',
                  style: AppTextStyles.labelLg.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Agronomist · Online',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling Dr. Chipo...')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('More options')),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Knowledge base tip
          Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.accent, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Tip: Share photos of your crops for better diagnosis',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const Icon(Icons.close, size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _buildMessage(_messages[i]),
            ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(_ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: message.isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.lg),
            topRight: const Radius.circular(AppRadius.lg),
            bottomLeft: Radius.circular(message.isMe ? AppRadius.lg : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : AppRadius.lg),
          ),
          border: message.isMe
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.file(
                  File(message.imagePath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              message.text,
              style: AppTextStyles.bodyMd.copyWith(
                color: message.isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message.time,
              style: AppTextStyles.caption.copyWith(
                color: message.isMe
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            color: AppColors.textTertiary,
            onPressed: () async {
              try {
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null && mounted) {
                  setState(() {
                    _messages.add(_ChatMessage(
                      text: '📷 Image attached',
                      isMe: true,
                      sender: 'You',
                      time: 'Now',
                      imagePath: image.path,
                    ));
                  });
                  _scrollToBottom();
                  
                  // Simulate Dr. Chipo reply
                  Future.delayed(const Duration(milliseconds: 2000), () {
                    if (!mounted) return;
                    setState(() {
                      _messages.add(_ChatMessage(
                        text: 'Looking at that photo, it definitely looks like Fall Armyworm damage. You should apply a contact insecticide immediately.',
                        isMe: false,
                        sender: 'Dr. Chipo Nyathi',
                        time: 'Now',
                      ));
                    });
                    _scrollToBottom();
                  });
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error picking image: $e')),
                  );
                }
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, size: 20),
              color: Colors.white,
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String sender;
  final String time;
  final String? imagePath;

  _ChatMessage({
    required this.text,
    required this.isMe,
    required this.sender,
    required this.time,
    this.imagePath,
  });
}
