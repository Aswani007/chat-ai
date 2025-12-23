import 'package:ai_chat_assistant/models/job_status.dart';

class PollResponse {
  final String jobId;
  final JobStatus status;
  final int? progress;
  final String? result;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String? error;

  PollResponse({
    required this.jobId,
    required this.status,
    this.progress,
    this.result,
    this.imageUrl,
    this.data,
    this.error,
  });

  factory PollResponse.fromJson(Map<String, dynamic> json) {
    return PollResponse(
      jobId: json['jobId'] as String,
      status: JobStatusExtension.fromString(json['status'] as String),
      progress: json['progress'] as int?,
      result: json['result'] as String?,
      imageUrl: json['imageUrl'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'status': status.name,
      'progress': progress,
      'result': result,
      'imageUrl': imageUrl,
      'data': data,
      'error': error,
    };
  }
}


