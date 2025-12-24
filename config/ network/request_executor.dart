// lib/config/network/request_executor.dart
import 'dart:async';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import 'api_result.dart';
import 'network_error.dart';

abstract class NetworkLogger {
  void logRequest({
    String? label,
  });

  void logSuccess({
    String? label,
    Object? response,
  });

  void logError({
    String? label,
    Object? error,
    StackTrace? stackTrace,
    NetworkError? networkError,
  });
}

class ConsoleNetworkLogger implements NetworkLogger {
  const ConsoleNetworkLogger();

  @override
  void logRequest({String? label}) {
    if (kDebugMode) {
      debugPrint('[Request] ${label ?? 'request'}');
    }
  }

  @override
  void logSuccess({String? label, Object? response}) {
    if (kDebugMode) {
      debugPrint('[Success] ${label ?? 'request'} -> $response');
    }
  }

  @override
  void logError({
    String? label,
    Object? error,
    StackTrace? stackTrace,
    NetworkError? networkError,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[Error] ${label ?? 'request'} -> $error, mapped: $networkError',
      );
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}

class RequestExecutor {
  RequestExecutor({
    NetworkLogger? logger,
  }) : _logger = logger ?? const ConsoleNetworkLogger();

  final NetworkLogger _logger;

  /// هر جایی که call Appwrite داری، ببرش داخل این متد
  ///
  /// مثال:
  /// executor.execute(() => _db.listDocuments(...));
  Future<ApiResult<T>> execute<T>(
      Future<T> Function() action, {
        Duration? timeout,
        String? label,
      }) async {
    _logger.logRequest(label: label);

    try {
      final Future<T> future = action();

      final T result;
      if (timeout != null) {
        result = await future.timeout(timeout);
      } else {
        result = await future;
      }

      _logger.logSuccess(label: label, response: result);
      return ApiResult.success(result);
    } on TimeoutException catch (e, st) {
      final error = NetworkError.timeout(
        devMessage: e.message,
        originalException: e,
      );
      _logger.logError(
        label: label,
        error: e,
        stackTrace: st,
        networkError: error,
      );
      return ApiResult.failure(error);
    } on SocketException catch (e, st) {
      final error = NetworkError.network(
        devMessage: e.message,
        originalException: e,
      );
      _logger.logError(
        label: label,
        error: e,
        stackTrace: st,
        networkError: error,
      );
      return ApiResult.failure(error);
    } on AppwriteException catch (e, st) {
      final error = NetworkError.fromAppwriteException(e);
      _logger.logError(
        label: label,
        error: e,
        stackTrace: st,
        networkError: error,
      );
      return ApiResult.failure(error);
    } on FormatException catch (e, st) {
      final error = NetworkError.serialization(
        devMessage: e.message,
        originalException: e,
      );
      _logger.logError(
        label: label,
        error: e,
        stackTrace: st,
        networkError: error,
      );
      return ApiResult.failure(error);
    } catch (e, st) {
      final error = NetworkError.unknown(
        devMessage: e.toString(),
        originalException: e,
      );
      _logger.logError(
        label: label,
        error: e,
        stackTrace: st,
        networkError: error,
      );
      return ApiResult.failure(error);
    }
  }
}
