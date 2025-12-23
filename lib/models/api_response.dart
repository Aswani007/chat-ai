import 'package:ai_chat_assistant/models/response_type.dart';

class ApiResponse {
  final ResponseType type;
  final String? content;
  final String? jobId;
  final String? error;

  ApiResponse({
    required this.type,
    this.content,
    this.jobId,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      type: ResponseTypeExtension.fromString(json['type'] as String),
      content: json['content'] as String?,
      jobId: json['jobId'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'content': content,
      'jobId': jobId,
      'error': error,
    };
  }
}


