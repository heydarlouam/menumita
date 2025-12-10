// lib/config/network/api_result.dart
import 'network_error.dart';

class ApiResult<T> {
  final T? data;
  final NetworkError? error;

  const ApiResult._({
    this.data,
    this.error,
  });

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  static ApiResult<T> success<T>(T data) {
    return ApiResult._(data: data);
  }

  static ApiResult<void> successNoData() {
    return const ApiResult._(data: null);
  }

  static ApiResult<T> failure<T>(NetworkError error) {
    return ApiResult._(error: error);
  }

  /// اگر call موفق نباشد، خطا می‌دهد.
  T requireData() {
    if (data == null) {
      throw StateError(
        'ApiResult has no data. Error: ${error?.devMessage ?? error?.userMessage}',
      );
    }
    return data as T;
  }

  /// اگر call موفق باشد، خطا می‌دهد.
  NetworkError requireError() {
    if (error == null) {
      throw StateError('ApiResult has no error. Data: $data');
    }
    return error!;
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResult.success(data: $data)';
    }
    return 'ApiResult.failure(error: $error)';
  }
}
