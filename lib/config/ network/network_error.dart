// lib/config/network/network_error.dart
import 'package:appwrite/appwrite.dart';

enum NetworkErrorType {
  network,
  server,
  unauthorized,
  forbidden,
  notFound,
  timeout,
  validation,
  cancelled,
  serialization,
  unknown,
}

class NetworkError {
  final NetworkErrorType type;
  final String userMessage;
  final String? devMessage;
  final int? statusCode;
  final String? code;
  final Object? originalException;
  final Map<String, dynamic>? details;

  const NetworkError({
    required this.type,
    required this.userMessage,
    this.devMessage,
    this.statusCode,
    this.code,
    this.originalException,
    this.details,
  });

  factory NetworkError.network({
    String userMessage = 'مشکل در اتصال به سرور. اتصال اینترنت را بررسی کنید.',
    String? devMessage,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.network,
      userMessage: userMessage,
      devMessage: devMessage,
      originalException: originalException,
    );
  }

  factory NetworkError.timeout({
    String userMessage = 'پاسخ سرور بیش از حد طول کشید، لطفاً دوباره تلاش کنید.',
    String? devMessage,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.timeout,
      userMessage: userMessage,
      devMessage: devMessage,
      originalException: originalException,
    );
  }

  factory NetworkError.server({
    int? statusCode,
    String userMessage = 'خطای داخلی سرور رخ داد.',
    String? devMessage,
    Object? originalException,
    Map<String, dynamic>? details,
  }) {
    return NetworkError(
      type: NetworkErrorType.server,
      userMessage: userMessage,
      devMessage: devMessage,
      statusCode: statusCode,
      originalException: originalException,
      details: details,
    );
  }

  factory NetworkError.unauthorized({
    int? statusCode,
    String userMessage = 'دسترسی غیرمجاز. لطفاً دوباره وارد شوید.',
    String? devMessage,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.unauthorized,
      userMessage: userMessage,
      devMessage: devMessage,
      statusCode: statusCode,
      originalException: originalException,
    );
  }

  factory NetworkError.forbidden({
    int? statusCode,
    String userMessage = 'شما مجوز انجام این عملیات را ندارید.',
    String? devMessage,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.forbidden,
      userMessage: userMessage,
      devMessage: devMessage,
      statusCode: statusCode,
      originalException: originalException,
    );
  }

  factory NetworkError.notFound({
    int? statusCode,
    String userMessage = 'مورد درخواستی پیدا نشد.',
    String? devMessage,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.notFound,
      userMessage: userMessage,
      devMessage: devMessage,
      statusCode: statusCode,
      originalException: originalException,
    );
  }

  factory NetworkError.validation({
    String userMessage = 'برخی از مقادیر وارد شده معتبر نیستند.',
    String? devMessage,
    Map<String, dynamic>? details,
    int? statusCode,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.validation,
      userMessage: userMessage,
      devMessage: devMessage,
      statusCode: statusCode,
      originalException: originalException,
      details: details,
    );
  }

  factory NetworkError.cancelled({
    String userMessage = 'درخواست لغو شد.',
    String? devMessage,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.cancelled,
      userMessage: userMessage,
      devMessage: devMessage,
      originalException: originalException,
    );
  }

  factory NetworkError.serialization({
    String userMessage = 'خطا در پردازش پاسخ سرور.',
    String? devMessage,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.serialization,
      userMessage: userMessage,
      devMessage: devMessage,
      originalException: originalException,
    );
  }

  factory NetworkError.unknown({
    String userMessage = 'یک خطای ناشناخته رخ داد.',
    String? devMessage,
    Object? originalException,
  }) {
    return NetworkError(
      type: NetworkErrorType.unknown,
      userMessage: userMessage,
      devMessage: devMessage,
      originalException: originalException,
    );
  }

  /// Map کردن AppwriteException به NetworkError
  factory NetworkError.fromAppwriteException(AppwriteException e) {
    final status = e.code;
    final msg = e.message ?? 'خطای نامشخص از سمت Appwrite';

    if (status == 401) {
      return NetworkError.unauthorized(
        statusCode: status,
        devMessage: msg,
        originalException: e,
      );
    }
    if (status == 403) {
      return NetworkError.forbidden(
        statusCode: status,
        devMessage: msg,
        originalException: e,
      );
    }
    if (status == 404) {
      return NetworkError.notFound(
        statusCode: status,
        devMessage: msg,
        originalException: e,
      );
    }
    if (status != null && status >= 400 && status < 500) {
      return NetworkError.validation(
        statusCode: status,
        devMessage: msg,
        originalException: e,
        details: e.response as Map<String, dynamic>?,
      );
    }
    if (status != null && status >= 500) {
      return NetworkError.server(
        statusCode: status,
        devMessage: msg,
        originalException: e,
        details: e.response as Map<String, dynamic>?,
      );
    }
    return NetworkError.unknown(
      devMessage: msg,
      originalException: e,
    );
  }

  @override
  String toString() {
    return 'NetworkError(type: $type, statusCode: $statusCode, code: $code, '
        'userMessage: $userMessage, devMessage: $devMessage, details: $details)';
  }
}
