import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_chat_assistant/controllers/chat_controller.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController textController = TextEditingController();
  late final ChatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChatController>();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 24 : 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                enabled: !controller.isLoading.value,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => IconButton(
                onPressed: controller.isLoading.value
                    ? null
                    : _sendMessage,
                icon: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = textController.text.trim();
    if (text.isNotEmpty) {
      controller.sendMessage(text);
      textController.clear();
    }
  }
}
