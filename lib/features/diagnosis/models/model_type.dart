// lib/features/diagnosis/models/model_type.dart
import 'package:ultralytics_yolo/yolo.dart';

enum ModelType {
  detect,
  segment,
  classify,
}

extension ModelTypeExtension on ModelType {
  String get name {
    switch (this) {
      case ModelType.detect:
        return 'Detect';
      case ModelType.segment:
        return 'Segment';
      case ModelType.classify:
        return 'Classify';
    }
  }

  String get modelName {
    switch (this) {
      case ModelType.detect:
        return '객체 감지 모델';
      case ModelType.segment:
        return '세그먼트 모델';
      case ModelType.classify:
        return '분류 모델';
    }
  }
}
