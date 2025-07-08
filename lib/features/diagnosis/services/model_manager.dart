class ModelManager {
  final void Function(double progress)? onDownloadProgress;
  final void Function(String status)? onStatusUpdate;

  ModelManager({
    this.onDownloadProgress,
    this.onStatusUpdate,
  });

  void updateProgress(double value) {
    if (onDownloadProgress != null) {
      onDownloadProgress!(value);
    }
  }

  void updateStatus(String message) {
    if (onStatusUpdate != null) {
      onStatusUpdate!(message);
    }
  }
}
