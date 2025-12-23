import 'dart:async';
import 'package:get/get.dart';
import 'package:ai_chat_assistant/models/chat_message.dart';
import 'package:ai_chat_assistant/models/api_response.dart';
import 'package:ai_chat_assistant/models/poll_response.dart';
import 'package:ai_chat_assistant/models/response_type.dart';
import 'package:ai_chat_assistant/models/job_status.dart';
import 'package:ai_chat_assistant/services/mock_backend_service.dart';

class ChatController extends GetxController {
  final MockBackendService _backendService = MockBackendService();

  // Configurable polling interval in seconds (default: 2-3 seconds)
  final int pollingIntervalSeconds = 2;

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> error = Rx<String?>(null);
  final RxMap<String, Timer> activePollingJobs = <String, Timer>{}.obs;
  final RxMap<String, ChatMessage> waitingMessages = <String, ChatMessage>{}.obs;

  @override
  void onClose() {
    // Cleanup all active polling timers
    for (var timer in activePollingJobs.values) {
      timer.cancel();
    }
    activePollingJobs.clear();
    super.onClose();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isLoading.value) return;

    // Clear any previous errors
    error.value = null;

    // Create user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Optimistic UI update
    messages.add(userMessage);

    // Disable input
    isLoading.value = true;

    try {
      // Send to backend
      final response = await _backendService.sendChatMessage(text.trim());

      // Handle different response types
      switch (response.type) {
        case ResponseType.text:
          _handleTextResponse(response);
          break;
        case ResponseType.imageGeneration:
          _handleImageGenerationResponse(response);
          break;
        case ResponseType.dataProcessing:
          _handleDataProcessingResponse(response);
          break;
      }
    } catch (e) {
      _handleError('Failed to send message: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleTextResponse(ApiResponse response) {
    if (response.error != null) {
      _handleError(response.error!);
      return;
    }

    final assistantMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response.content ?? 'No response received',
      isUser: false,
      timestamp: DateTime.now(),
      responseType: ResponseType.text,
    );

    messages.add(assistantMessage);
  }

  void _handleImageGenerationResponse(ApiResponse response) {
    if (response.error != null || response.jobId == null) {
      _handleError(response.error ?? 'No job ID received for image generation');
      return;
    }

    final waitingMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Generating image...',
      isUser: false,
      timestamp: DateTime.now(),
      responseType: ResponseType.imageGeneration,
      jobId: response.jobId,
      jobStatus: JobStatus.pending,
    );

    messages.add(waitingMessage);
    waitingMessages[response.jobId!] = waitingMessage;
    _startPolling(response.jobId!);
  }

  void _handleDataProcessingResponse(ApiResponse response) {
    if (response.error != null || response.jobId == null) {
      _handleError(response.error ?? 'No job ID received for data processing');
      return;
    }

    final waitingMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Processing data...',
      isUser: false,
      timestamp: DateTime.now(),
      responseType: ResponseType.dataProcessing,
      jobId: response.jobId,
      jobStatus: JobStatus.pending,
    );

    messages.add(waitingMessage);
    waitingMessages[response.jobId!] = waitingMessage;
    _startPolling(response.jobId!);
  }

  void _startPolling(String jobId) {
    // Cancel existing timer if any
    activePollingJobs[jobId]?.cancel();

    // Start polling at configured interval
    final timer = Timer.periodic(Duration(seconds: pollingIntervalSeconds), (timer) async {
      try {
        final pollResponse = await _backendService.pollJob(jobId);

        if (pollResponse.status == JobStatus.completed) {
          _handlePollingComplete(jobId, pollResponse);
          timer.cancel();
          activePollingJobs.remove(jobId);
          waitingMessages.remove(jobId);
        } else if (pollResponse.status == JobStatus.failed) {
          _handlePollingFailure(jobId, pollResponse);
          timer.cancel();
          activePollingJobs.remove(jobId);
          waitingMessages.remove(jobId);
        } else {
          _handlePollingUpdate(jobId, pollResponse);
        }
      } catch (e) {
        // Handle network errors or timeouts
        _handlePollingError(jobId, e.toString());
        timer.cancel();
        activePollingJobs.remove(jobId);
        waitingMessages.remove(jobId);
      }
    });

    activePollingJobs[jobId] = timer;
  }

  void _handlePollingUpdate(String jobId, PollResponse response) {
    final waitingMessage = waitingMessages[jobId];
    if (waitingMessage == null) return;

    final index = messages.indexWhere((msg) => msg.id == waitingMessage.id);
    if (index == -1) return;

    final updatedMessage = waitingMessage.copyWith(
      jobStatus: response.status,
      content: _getProgressMessage(waitingMessage.responseType, response.progress ?? 0),
    );

    messages[index] = updatedMessage;
    waitingMessages[jobId] = updatedMessage;
  }

  void _handlePollingComplete(String jobId, PollResponse response) {
    final waitingMessage = waitingMessages[jobId];
    if (waitingMessage == null) return;

    final index = messages.indexWhere((msg) => msg.id == waitingMessage.id);
    if (index == -1) return;

    ChatMessage completedMessage;

    if (waitingMessage.responseType == ResponseType.imageGeneration) {
      completedMessage = waitingMessage.copyWith(
        jobStatus: JobStatus.completed,
        content: 'Image generated successfully!',
        imageUrl: response.imageUrl,
      );
    } else if (waitingMessage.responseType == ResponseType.dataProcessing) {
      completedMessage = waitingMessage.copyWith(
        jobStatus: JobStatus.completed,
        content: 'Data processing completed!',
        processedData: response.data,
      );
    } else {
      completedMessage = waitingMessage.copyWith(
        jobStatus: JobStatus.completed,
        content: response.result ?? 'Completed',
      );
    }

    messages[index] = completedMessage;
  }

  void _handlePollingFailure(String jobId, PollResponse response) {
    final waitingMessage = waitingMessages[jobId];
    if (waitingMessage == null) return;

    final index = messages.indexWhere((msg) => msg.id == waitingMessage.id);
    if (index == -1) return;

    final failedMessage = waitingMessage.copyWith(
      jobStatus: JobStatus.failed,
      content: 'Failed: ${response.error ?? "Unknown error"}',
      error: response.error ?? 'Unknown error',
    );

    messages[index] = failedMessage;
    error.value = response.error ?? 'Job failed';
  }

  void _handlePollingError(String jobId, String errorMessage) {
    final waitingMessage = waitingMessages[jobId];
    if (waitingMessage == null) return;

    final index = messages.indexWhere((msg) => msg.id == waitingMessage.id);
    if (index == -1) return;

    final errorMessageObj = waitingMessage.copyWith(
      jobStatus: JobStatus.failed,
      content: 'Error: $errorMessage',
      error: errorMessage,
    );

    messages[index] = errorMessageObj;
    error.value = errorMessage;
  }

  String _getProgressMessage(ResponseType? type, int progress) {
    switch (type) {
      case ResponseType.imageGeneration:
        return 'Generating image... $progress%';
      case ResponseType.dataProcessing:
        return 'Processing data... $progress%';
      default:
        return 'Processing... $progress%';
    }
  }

  void _handleError(String errorMessage) {
    error.value = errorMessage;

    // Add error message to chat
    final errorChatMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Error: $errorMessage',
      isUser: false,
      timestamp: DateTime.now(),
      error: errorMessage,
    );

    messages.add(errorChatMessage);
  }

  void clearError() {
    error.value = null;
  }

  void clearMessages() {
    // Cancel all active polling
    for (var timer in activePollingJobs.values) {
      timer.cancel();
    }
    activePollingJobs.clear();
    waitingMessages.clear();
    messages.clear();
    error.value = null;
  }
}

