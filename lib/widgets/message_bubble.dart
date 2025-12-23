import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:ai_chat_assistant/models/chat_message.dart';
import 'package:ai_chat_assistant/models/response_type.dart';
import 'package:ai_chat_assistant/models/job_status.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final maxWidth = isWeb 
        ? MediaQuery.of(context).size.width * 0.6
        : MediaQuery.of(context).size.width * 0.75;
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        margin: EdgeInsets.symmetric(
          vertical: 4,
          horizontal: isWeb ? 16 : 8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContent(context),
            const SizedBox(height: 4),
            _buildTimestamp(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Handle error messages
    if (message.error != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.content,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }

    // Handle different response types
    if (!message.isUser && message.responseType != null) {
      switch (message.responseType!) {
        case ResponseType.text:
          return Text(
            message.content,
            style: TextStyle(
              color: message.isUser
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          );

        case ResponseType.imageGeneration:
          return _buildImageGenerationContent(context);

        case ResponseType.dataProcessing:
          return _buildDataProcessingContent(context);
      }
    }

    // Default text message
    return Text(
      message.content,
      style: TextStyle(
        color: message.isUser
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 14,
      ),
    );
  }

  Widget _buildImageGenerationContent(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 600;
    final imageWidth = isWeb ? 400.0 : 300.0;
    final imageHeight = isWeb ? 300.0 : 200.0;
    
    if (message.jobStatus == JobStatus.completed && message.imageUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              message.imageUrl!,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (message.jobStatus == JobStatus.processing ||
        message.jobStatus == JobStatus.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message.content,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    } else {
      return Text(
        message.content,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }
  }

  Widget _buildDataProcessingContent(BuildContext context) {
    if (message.jobStatus == JobStatus.completed &&
        message.processedData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(message.processedData),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      );
    } else if (message.jobStatus == JobStatus.processing ||
        message.jobStatus == JobStatus.pending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.content,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Text(
        message.content,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }
  }

  Widget _buildTimestamp(BuildContext context) {
    final time = message.timestamp;
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Text(
      timeString,
      style: TextStyle(
        color: message.isUser
            ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
        fontSize: 10,
      ),
    );
  }
}

