import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_connect.dart';

import '../utility/constants.dart';




// class _Net extends GetConnect {
//   _Net() {
//     httpClient.baseUrl = MAIN_URL;
//     httpClient.timeout = const Duration(seconds: 15);
//     httpClient.maxAuthRetries = 0;
//
//     // فقط Accept رو ست می‌کنیم؛ Content-Type را در خود کال‌ها تعیین می‌کنیم
//     httpClient.addRequestModifier<dynamic>((request) {
//       request.headers['Accept'] = 'application/json';
//       return request;
//     });
//
//
//   }
// }
//
// class HttpService {
//   // Singleton
//
//   String _path(String endpointUrl) =>
//       endpointUrl.startsWith('/') ? endpointUrl : '/$endpointUrl';
//
//   static final HttpService _instance = HttpService._internal();
//   factory HttpService() => _instance;
//   HttpService._internal();
//
//   final _Net _net = _Net();
//
//   Future<Response> _safeRequest(Future<Response> Function() run, {int retry = 1}) async {
//     Response res;
//     int attempts = 0;
//     while (true) {
//       attempts++;
//       try {
//         res = await run();
//         if (res.statusCode == null) {
//           return Response(
//             body: json.encode({'message': 'No status code from server'}),
//             statusCode: 599,
//           );
//         }
//         return res;
//       } catch (e) {
//         if (attempts > retry) {
//           return Response(
//             body: json.encode({'message': e.toString()}),
//             statusCode: 598,
//           );
//         }
//         await Future.delayed(Duration(milliseconds: 300 * attempts)); // backoff سبک
//       }
//     }
//   }
//
//   // ------ Helpers ------
//   bool _isFormData(dynamic body) => body is FormData;
//
//
//   dynamic _prepareBody(dynamic bodyOrMap) {
//     if (bodyOrMap == null) return {};
//     if (bodyOrMap is FormData) return bodyOrMap;
//     if (bodyOrMap is String) return bodyOrMap; // JSON string
//     if (bodyOrMap is Map<String, dynamic>) return bodyOrMap; // Map
//     // fallback: تبدیل به JSON string
//     return json.encode(bodyOrMap);
//   }
//
//
//   Future<Response> getItems({required String endpointUrl}) {
//     return _safeRequest(() => _net.get(_path(endpointUrl)));
//   }
//
//   Future<Response> postItem({
//     required String endpointUrl,
//     dynamic body,
//     dynamic itemData,
//   }) {
//     final payload = _prepareBody(body ?? itemData);
//     if (_isFormData(payload)) {
//       return _safeRequest(() => _net.post(_path(endpointUrl), payload));
//     } else {
//       return _safeRequest(() => _net.post(_path(endpointUrl), payload,
//           contentType: 'application/json'));
//     }
//   }
//
//   Future<Response> addItem({
//     required String endpointUrl,
//     dynamic itemData,
//     dynamic body,
//   }) {
//     final payload = _prepareBody(body ?? itemData);
//     if (_isFormData(payload)) {
//       return _safeRequest(() => _net.post(_path(endpointUrl), payload));
//     } else {
//       return _safeRequest(() => _net.post(_path(endpointUrl), payload,
//           contentType: 'application/json'));
//     }
//   }
//
//   Future<Response> updateItem({
//     required String endpointUrl,
//     required String itemId,
//     dynamic body,
//     dynamic itemData,
//   }) {
//     final payload = _prepareBody(body ?? itemData);
//     if (_isFormData(payload)) {
//       return _safeRequest(() => _net.put('${_path(endpointUrl)}/$itemId', payload));
//     } else {
//       return _safeRequest(() => _net.put('${_path(endpointUrl)}/$itemId', payload,
//           contentType: 'application/json'));
//     }
//   }
//
//   Future<Response> deleteItem({
//     required String endpointUrl,
//     required String itemId,
//   }) {
//     return _safeRequest(() => _net.delete('${_path(endpointUrl)}/$itemId'));
//   }
//
//
// }


// lib/services/http_services.dart
import 'dart:convert';
import 'package:get/get.dart';
import '../utility/constants.dart';

class _Net extends GetConnect {
  _Net() {
    httpClient.baseUrl = MAIN_URL; // پیشنهاد: از --dart-define برای MAIN_URL استفاده کن
    httpClient.timeout = const Duration(seconds: 15);
    httpClient.maxAuthRetries = 0;

    // درخواست‌ها
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      request.headers['Accept-Encoding'] = 'gzip, deflate, br'; // برای پاسخ فشرده
      // اگر auth داری، اینجا Authorization رو ست کن
      return request;
    });

    // پاسخ‌ها
    httpClient.addResponseModifier((request, response) {
      // می‌تونی لاگ سطح پایین اینجا بذاری (در حالت debug)
      return response;
    });
  }
}

class HttpService {
  // Singleton
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  final _Net _net = _Net();

  String _path(String endpointUrl) =>
      endpointUrl.startsWith('/') ? endpointUrl : '/$endpointUrl';

  Future<Response> _safeRequest(
      Future<Response> Function() run, {
        int maxRetry = 2, // 2 بار retry → مجموعاً 3 تلاش
      }) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final res = await run();
        if (res.statusCode == null) {
          return Response(
            body: json.encode({'message': 'No status code from server'}),
            statusCode: 599,
          );
        }
        return res;
      } catch (e) {
        if (attempt > maxRetry) {
          return Response(
            body: json.encode({'message': e.toString()}),
            statusCode: 598,
          );
        }
        // backoff افزایشی: 300ms، 600ms، 900ms...
        await Future.delayed(Duration(milliseconds: 300 * attempt));
      }
    }
  }

  bool _isFormData(dynamic body) => body is FormData;

  dynamic _prepareBody(dynamic bodyOrMap) {
    if (bodyOrMap == null) return {};
    if (bodyOrMap is FormData) return bodyOrMap;
    if (bodyOrMap is String) return bodyOrMap; // JSON string
    if (bodyOrMap is Map<String, dynamic>) return bodyOrMap;
    return json.encode(bodyOrMap); // fallback
  }

  Future<Response> getItems({required String endpointUrl}) {
    return _safeRequest(() => _net.get(_path(endpointUrl)));
  }

  Future<Response> postItem({
    required String endpointUrl,
    dynamic body,
    dynamic itemData,
  }) {
    final payload = _prepareBody(body ?? itemData);
    if (_isFormData(payload)) {
      return _safeRequest(() => _net.post(_path(endpointUrl), payload));
    } else {
      return _safeRequest(() => _net.post(_path(endpointUrl), payload,
          contentType: 'application/json'));
    }
  }

  Future<Response> addItem({
    required String endpointUrl,
    dynamic itemData,
    dynamic body,
  }) {
    final payload = _prepareBody(body ?? itemData);
    if (_isFormData(payload)) {
      return _safeRequest(() => _net.post(_path(endpointUrl), payload));
    } else {
      return _safeRequest(() => _net.post(_path(endpointUrl), payload,
          contentType: 'application/json'));
    }
  }

  Future<Response> updateItem({
    required String endpointUrl,
    required String itemId,
    dynamic body,
    dynamic itemData,
  }) {
    final payload = _prepareBody(body ?? itemData);
    if (_isFormData(payload)) {
      return _safeRequest(
              () => _net.put('${_path(endpointUrl)}/$itemId', payload));
    } else {
      return _safeRequest(
            () => _net.put('${_path(endpointUrl)}/$itemId', payload,
            contentType: 'application/json'),
      );
    }
  }

  Future<Response> deleteItem({
    required String endpointUrl,
    required String itemId,
  }) {
    return _safeRequest(() => _net.delete('${_path(endpointUrl)}/$itemId'));
  }
}
