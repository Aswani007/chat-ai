enum JobStatus {
  pending,
  processing,
  completed,
  failed,
}

extension JobStatusExtension on JobStatus {
  String get name {
    switch (this) {
      case JobStatus.pending:
        return 'pending';
      case JobStatus.processing:
        return 'processing';
      case JobStatus.completed:
        return 'completed';
      case JobStatus.failed:
        return 'failed';
    }
  }

  static JobStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return JobStatus.pending;
      case 'processing':
        return JobStatus.processing;
      case 'completed':
        return JobStatus.completed;
      case 'failed':
        return JobStatus.failed;
      default:
        return JobStatus.pending;
    }
  }
}


