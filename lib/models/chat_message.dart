import 'package:ai_chat_assistant/models/response_type.dart';
import 'package:ai_chat_assistant/models/job_status.dart';

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ResponseType? responseType;
  final String? jobId;
  final JobStatus? jobStatus;
  final String? imageUrl;
  final Map<String, dynamic>? processedData;
  final String? error;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.responseType,
    this.jobId,
    this.jobStatus,
    this.imageUrl,
    this.processedData,
    this.error,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    ResponseType? responseType,
    String? jobId,
    JobStatus? jobStatus,
    String? imageUrl,
    Map<String, dynamic>? processedData,
    String? error,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      responseType: responseType ?? this.responseType,
      jobId: jobId ?? this.jobId,
      jobStatus: jobStatus ?? this.jobStatus,
      imageUrl: imageUrl ?? this.imageUrl,
      processedData: processedData ?? this.processedData,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'responseType': responseType?.name,
      'jobId': jobId,
      'jobStatus': jobStatus?.name,
      'imageUrl': imageUrl,
      'processedData': processedData,
      'error': error,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      responseType: json['responseType'] != null
          ? ResponseTypeExtension.fromString(json['responseType'] as String)
          : null,
      jobId: json['jobId'] as String?,
      jobStatus: json['jobStatus'] != null
          ? JobStatusExtension.fromString(json['jobStatus'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      processedData: json['processedData'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }
}


