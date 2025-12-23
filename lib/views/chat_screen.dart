import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_chat_assistant/controllers/chat_controller.dart';
import 'package:ai_chat_assistant/widgets/message_bubble.dart';
import 'package:ai_chat_assistant/widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    final scrollController = ScrollController();
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant'),
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: controller.messages.isEmpty
                  ? null
                  : () {
                      controller.clearMessages();
                    },
              tooltip: 'Clear chat',
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWeb ? 800 : double.infinity,
          ),
          child: Column(
            children: [
          // Error banner
          Obx(
            () {
              final errorMessage = controller.error.value;
              return errorMessage != null
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            size: 20,
                          ),
                          onPressed: () => controller.clearError(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink();
            },
          ),

          // Messages list
          Expanded(
            child: Obx(
              () {
                if (controller.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      message: controller.messages[index],
                    );
                  },
                );
              },
            ),
          ),

          // Input field
          ChatInput(),
        ],
      ),
        ),
      ),
    );
  }
}

