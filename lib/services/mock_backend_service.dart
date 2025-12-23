import 'dart:math';
import 'package:ai_chat_assistant/models/api_response.dart';
import 'package:ai_chat_assistant/models/poll_response.dart';
import 'package:ai_chat_assistant/models/response_type.dart';
import 'package:ai_chat_assistant/models/job_status.dart';

class MockBackendService {
  static final MockBackendService _instance = MockBackendService._internal();
  factory MockBackendService() => _instance;
  MockBackendService._internal();

  final Random _random = Random();
  final Map<String, _JobState> _jobs = {};
  final Map<String, int> _jobProgress = {};

  // Simulate POST /chat endpoint
  Future<ApiResponse> sendChatMessage(String message) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    // Detect user intent from message
    final lowerMessage = message.toLowerCase().trim();
    
    // Check for image generation requests
    final imageKeywords = [
      'image',
      'generate image',
      'create image',
      'draw',
      'picture',
      'photo',
      'generate a picture',
      'create a picture',
    ];
    final isImageRequest = imageKeywords.any((keyword) => lowerMessage.contains(keyword));
    
    // Check for data processing requests
    final dataProcessingKeywords = [
      'process data',
      'data processing',
      'analyze data',
      'process',
      'analyze',
      'data analysis',
    ];
    final isDataProcessingRequest = dataProcessingKeywords.any((keyword) => lowerMessage.contains(keyword));

    // Determine response type based on user intent
    ResponseType selectedType;
    if (isImageRequest) {
      selectedType = ResponseType.imageGeneration;
    } else if (isDataProcessingRequest) {
      selectedType = ResponseType.dataProcessing;
    } else {
      // Default to text response for normal chat
      selectedType = ResponseType.text;
    }

    switch (selectedType) {
      case ResponseType.text:
        return ApiResponse(
          type: ResponseType.text,
          content: _generateTextResponse(message),
        );

      case ResponseType.imageGeneration:
        final jobId = _generateJobId();
        _initializeJob(jobId, ResponseType.imageGeneration);
        return ApiResponse(
          type: ResponseType.imageGeneration,
          jobId: jobId,
        );

      case ResponseType.dataProcessing:
        final jobId = _generateJobId();
        _initializeJob(jobId, ResponseType.dataProcessing);
        return ApiResponse(
          type: ResponseType.dataProcessing,
          jobId: jobId,
        );
    }
  }

  // Simulate GET /poll/{jobId} endpoint
  Future<PollResponse> pollJob(String jobId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final jobState = _jobs[jobId];
    if (jobState == null) {
      return PollResponse(
        jobId: jobId,
        status: JobStatus.failed,
        error: 'Job not found',
      );
    }

    // Simulate job progression
    final currentProgress = _jobProgress[jobId] ?? 0;
    final newProgress = (currentProgress + 10 + _random.nextInt(20)).clamp(0, 100);

    _jobProgress[jobId] = newProgress;

    // Determine status based on progress
    JobStatus status;
    if (newProgress >= 100) {
      status = JobStatus.completed;
      _jobs[jobId] = _JobState(
        type: jobState.type,
        status: status,
        completed: true,
      );
    } else if (_random.nextDouble() < 0.05) {
      // 5% chance of failure
      status = JobStatus.failed;
      _jobs[jobId] = _JobState(
        type: jobState.type,
        status: status,
        completed: true,
      );
      return PollResponse(
        jobId: jobId,
        status: status,
        progress: newProgress,
        error: 'Job processing failed unexpectedly',
      );
    } else {
      status = JobStatus.processing;
    }

    // Generate result based on job type when completed
    if (status == JobStatus.completed) {
      if (jobState.type == ResponseType.imageGeneration) {
        return PollResponse(
          jobId: jobId,
          status: status,
          progress: 100,
          imageUrl: 'https://picsum.photos/400/300?random=$jobId',
        );
      } else if (jobState.type == ResponseType.dataProcessing) {
        return PollResponse(
          jobId: jobId,
          status: status,
          progress: 100,
          data: _generateProcessedData(),
        );
      }
    }

    return PollResponse(
      jobId: jobId,
      status: status,
      progress: newProgress,
    );
  }

  void _initializeJob(String jobId, ResponseType type) {
    _jobs[jobId] = _JobState(
      type: type,
      status: JobStatus.pending,
      completed: false,
    );
    _jobProgress[jobId] = 0;
  }

  String _generateJobId() {
    return 'job_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }

  String _generateTextResponse(String userMessage) {
    final responses = [
      'I understand your question about "$userMessage". Let me help you with that.',
      'That\'s an interesting point. Based on what you\'ve shared, I think the best approach would be to consider multiple perspectives.',
      'Thank you for asking. Here\'s a comprehensive answer to your question.',
      'I\'ve analyzed your request and here are my thoughts on the matter.',
      'Great question! Let me break this down for you in a clear and concise way.',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  Map<String, dynamic> _generateProcessedData() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'recordsProcessed': 1000 + _random.nextInt(5000),
      'status': 'success',
      'metrics': {
        'averageProcessingTime': 2.5 + _random.nextDouble() * 3,
        'successRate': 0.95 + _random.nextDouble() * 0.05,
        'throughput': 500 + _random.nextInt(200),
      },
      'summary': {
        'totalItems': 5000 + _random.nextInt(10000),
        'processed': 5000 + _random.nextInt(10000),
        'errors': _random.nextInt(10),
      },
    };
  }

  // Cleanup method to remove old jobs (optional)
  void cleanupOldJobs() {
    _jobs.removeWhere((key, value) {
      // Remove jobs older than 1 hour (if we track timestamps)
      return false; // Simplified for now
    });
  }
}

class _JobState {
  final ResponseType type;
  final JobStatus status;
  final bool completed;

  _JobState({
    required this.type,
    required this.status,
    required this.completed,
  });
}

