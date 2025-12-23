enum ResponseType {
  text,
  imageGeneration,
  dataProcessing,
}

extension ResponseTypeExtension on ResponseType {
  String get name {
    switch (this) {
      case ResponseType.text:
        return 'text';
      case ResponseType.imageGeneration:
        return 'imageGeneration';
      case ResponseType.dataProcessing:
        return 'dataProcessing';
    }
  }

  static ResponseType fromString(String value) {
    switch (value) {
      case 'text':
        return ResponseType.text;
      case 'imageGeneration':
        return ResponseType.imageGeneration;
      case 'dataProcessing':
        return ResponseType.dataProcessing;
      default:
        return ResponseType.text;
    }
  }
}


