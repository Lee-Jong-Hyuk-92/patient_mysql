// lib/core/result.dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message; // 여기에 message 필드가 있습니다.
  const Failure(this.message);
}