// lib/config/network/api_result.dart
import 'network_error.dart';



/// نتیجه‌ی استاندارد همه‌ی درخواست‌های شبکه/دیتا در اپ.
///
/// - در حالت موفق: [data] پر است و [error] null
/// - در حالت خطا: [error] پر است و [data] null
class ApiResult<T> {
  final T? data;
  final NetworkError? error;

  const ApiResult._({this.data, this.error});

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  factory ApiResult.success(T data) => ApiResult._(data: data);

  /// برای عملیات‌هایی مثل delete که دیتا ندارند.
  factory ApiResult.successNoData() => const ApiResult._();

  factory ApiResult.failure(NetworkError error) => ApiResult._(error: error);

  /// سازگاری با کدهای فعلی پروژه (به صورت متد استفاده شده)
  T requireData() {
    final value = data;
    if (value == null) {
      throw StateError(
        'ApiResult has no data. Check isSuccess before calling requireData(). Error: ${error?.devMessage ?? error?.userMessage}',
      );
    }
    return value;
  }

  /// سازگاری با کدهای فعلی پروژه (به صورت متد استفاده شده)
  NetworkError requireError() {
    final value = error;
    if (value == null) {
      throw StateError(
        'ApiResult has no error. Check isFailure before calling requireError().',
      );
    }
    return value;
  }

  @override
  String toString() =>
      isSuccess ? 'ApiResult.success($data)' : 'ApiResult.failure($error)';
}
