// // lib/config/network/realtime_manager.dart
// import 'dart:async';
//
//
// import 'appwrite_client.dart';
//
// import 'package:appwrite/appwrite.dart';
//
// enum RealtimeAction {
//   create,
//   update,
//   delete,
//   unknown,
// }
//
// // class RealtimeEvent<T> {
// //   final RealtimeAction action;
// //   final T? data;
// //   final String? documentId;
// //   final Map<String, dynamic> raw;
// //
// //   RealtimeEvent({
// //     required this.action,
// //     required this.raw,
// //     this.data,
// //     this.documentId,
// //   });
// //
// //   @override
// //   String toString() {
// //     return 'RealtimeEvent(action: $action, documentId: $documentId, data: $data)';
// //   }
// // }
// class RealtimeEvent<T> {
//   final RealtimeAction action;
//   final T? data;
//   final String? documentId;
//   final Map<String, dynamic> raw;
//   final List<String> events; // ← اضافه شد
//
//   RealtimeEvent({
//     required this.action,
//     required this.raw,
//     required this.events, // ← required شد
//     this.data,
//     this.documentId,
//   });
//
//   @override
//   String toString() {
//     return 'RealtimeEvent(action: $action, documentId: $documentId, events: $events, data: $data)';
//   }
// }
// class RealtimeManager {
//   RealtimeManager._internal();
//
//   static final RealtimeManager instance = RealtimeManager._internal();
//
//   final Map<String, RealtimeSubscription> _subscriptions = {};
//   final Map<String, StreamController<RealtimeEvent<Map<String, dynamic>>>>
//   _controllers = {};
//
//   Realtime get _realtime => AppwriteClient.instance.realtime;
//
//   String _channelsKey(List<String> channels) => channels.join(',');
//
//   Stream<RealtimeEvent<Map<String, dynamic>>> subscribeRaw(List<String> channels) {
//     final key = _channelsKey(channels);
//
//     if (_controllers.containsKey(key)) {
//       return _controllers[key]!.stream;
//     }
//
//     final controller =
//     StreamController<RealtimeEvent<Map<String, dynamic>>>.broadcast();
//
//     final subscription = _realtime.subscribe(channels);
//
//     subscription.stream.listen(
//           (RealtimeMessage message) {
//         try {
//           final payload = Map<String, dynamic>.from(message.payload as Map);
//           final events = message.events;
//           final action = _extractAction(events);
//
//           final documentId =
//               payload[r'$id']?.toString() ?? payload['\$id']?.toString();
//
//           // controller.add(
//           //   RealtimeEvent<Map<String, dynamic>>(
//           //     action: action,
//           //     raw: payload,
//           //     data: payload,
//           //     documentId: documentId,
//           //   ),
//           // );
//           controller.add(
//             RealtimeEvent<Map<String, dynamic>>(
//               action: action,
//               raw: payload,
//               data: payload,
//               documentId: documentId,
//               events: message.events, // ← اضافه شد
//             ),
//           );
//         } catch (_) {
//           // در صورت نیاز می‌توانی اینجا لاگ بگیری
//         }
//       },
//       onError: (error, stackTrace) {
//         // در صورت نیاز می‌توانی خطا را لاگ کنی
//       },
//       cancelOnError: false,
//     );
//
//     _subscriptions[key] = subscription;
//     _controllers[key] = controller;
//
//     return controller.stream;
//   }
//
//   Stream<RealtimeEvent<Map<String, dynamic>>> subscribeCollectionRaw({
//     required String databaseId,
//     required String collectionId,
//   }) {
//     final channel = 'databases.$databaseId.collections.$collectionId.documents';
//     return subscribeRaw([channel]);
//   }
//
//   Stream<RealtimeEvent<T>> subscribeCollection<T>({
//     required String databaseId,
//     required String collectionId,
//     required T Function(Map<String, dynamic> json) fromJson,
//   }) {
//     final rawStream = subscribeCollectionRaw(
//       databaseId: databaseId,
//       collectionId: collectionId,
//     );
//
//     return rawStream.map((rawEvent) {
//       final data = rawEvent.data != null ? fromJson(rawEvent.data!) : null;
//       // return RealtimeEvent<T>(
//       //   action: rawEvent.action,
//       //   raw: rawEvent.raw,
//       //   data: data,
//       //   documentId: rawEvent.documentId,
//       // );
//       return RealtimeEvent<T>(
//         action: rawEvent.action,
//         raw: rawEvent.raw,
//         data: data,
//         documentId: rawEvent.documentId,
//         events: rawEvent.events, // ← اضافه شد
//       );
//     });
//   }
//
//   void unsubscribe(List<String> channels) {
//     final key = _channelsKey(channels);
//
//     _subscriptions.remove(key)?.close();
//     _controllers.remove(key)?.close();
//   }
//
//   void unsubscribeCollection({
//     required String databaseId,
//     required String collectionId,
//   }) {
//     final channel = 'databases.$databaseId.collections.$collectionId.documents';
//     unsubscribe([channel]);
//   }
//
//   void dispose() {
//     for (final sub in _subscriptions.values) {
//       sub.close();
//     }
//     _subscriptions.clear();
//
//     for (final c in _controllers.values) {
//       c.close();
//     }
//     _controllers.clear();
//   }
//
//
//   RealtimeAction _extractAction(List<String> events) {
//     if (events.any((e) => e.endsWith('.create'))) return RealtimeAction.create;
//     if (events.any((e) => e.endsWith('.update'))) return RealtimeAction.update;
//     if (events.any((e) => e.endsWith('.delete'))) return RealtimeAction.delete;
//     return RealtimeAction.unknown;
//   }
// }


// lib/config/network/realtime_manager.dart
// import 'dart:async';
// import 'package:appwrite/appwrite.dart';
//
// import 'appwrite_client.dart';
//
// enum RealtimeAction {
//   create,
//   update,
//   delete,
//   unknown,
// }
//
// class RealtimeEvent<T> {
//   final RealtimeAction action;
//   final T? data;
//
//   /// docId نهایی (حتی برای delete با payload خالی)
//   final String? documentId;
//
//   /// payload خام (ممکنه برای delete خالی باشد)
//   final Map<String, dynamic> raw;
//
//   /// ✅ events اصلی Appwrite (برای استخراج docId / debug)
//   final List<String> events;
//
//   RealtimeEvent({
//     required this.action,
//     required this.raw,
//     this.data,
//     this.documentId,
//     this.events = const [],
//   });
//
//   @override
//   String toString() {
//     return 'RealtimeEvent(action: $action, documentId: $documentId, events: $events, data: $data)';
//   }
// }
//
// class RealtimeManager {
//   RealtimeManager._internal();
//   static final RealtimeManager instance = RealtimeManager._internal();
//
//   final Map<String, RealtimeSubscription> _subscriptions = {};
//   final Map<String, StreamController<RealtimeEvent<Map<String, dynamic>>>>
//   _controllers = {};
//
//   Realtime get _realtime => AppwriteClient.instance.realtime;
//
//   String _channelsKey(List<String> channels) => channels.join(',');
//
//   // -----------------------
//   // Helpers
//   // -----------------------
//   RealtimeAction _extractAction(List<String> events) {
//     if (events.any((e) => e.endsWith('.create'))) return RealtimeAction.create;
//     if (events.any((e) => e.endsWith('.update'))) return RealtimeAction.update;
//     if (events.any((e) => e.endsWith('.delete'))) return RealtimeAction.delete;
//     return RealtimeAction.unknown;
//   }
//
//   /// استخراج docId از events مثل:
//   /// databases.{db}.collections.{col}.documents.{id}.delete
//   String? _extractDocIdFromEvents(List<String> events) {
//     for (final e in events) {
//       final i = e.indexOf('.documents.');
//       if (i == -1) continue;
//
//       final tail = e.substring(i + '.documents.'.length);
//       final dot = tail.indexOf('.');
//       if (dot == -1) continue;
//
//       final id = tail.substring(0, dot).trim();
//       if (id.isNotEmpty) return id;
//     }
//     return null;
//   }
//
//   Stream<RealtimeEvent<Map<String, dynamic>>> subscribeRaw(List<String> channels) {
//     final key = _channelsKey(channels);
//
//     final existing = _controllers[key];
//     if (existing != null && !existing.isClosed) {
//       return existing.stream;
//     }
//
//     final controller =
//     StreamController<RealtimeEvent<Map<String, dynamic>>>.broadcast();
//
//     final subscription = _realtime.subscribe(channels);
//
//     subscription.stream.listen(
//           (RealtimeMessage message) {
//         try {
//           final events = List<String>.from(message.events);
//           final action = _extractAction(events);
//
//           // payload ممکنه برای delete خالی یا غیر map باشد
//           Map<String, dynamic> payload = <String, dynamic>{};
//           final rawPayload = message.payload;
//           if (rawPayload is Map) {
//             payload = Map<String, dynamic>.from(rawPayload);
//           }
//
//           // documentId: اول payload، بعد events
//           String? documentId =
//               payload[r'$id']?.toString() ?? payload['\$id']?.toString();
//
//           if (documentId == null || documentId.trim().isEmpty) {
//             documentId = _extractDocIdFromEvents(events);
//           }
//           documentId = documentId?.trim();
//
//           // ✅ اگر payload خالی بود، data را null بگذار تا fromJson اجرا نشود
//           final Map<String, dynamic>? data = payload.isNotEmpty ? payload : null;
//
//           controller.add(
//             RealtimeEvent<Map<String, dynamic>>(
//               action: action,
//               raw: payload,
//               data: data,
//               documentId: documentId,
//               events: events,
//             ),
//           );
//         } catch (_) {
//           // اگر خواستی اینجا log بگیر
//         }
//       },
//       onError: (error, stackTrace) {
//         // اگر خواستی اینجا log بگیر
//       },
//       cancelOnError: false,
//     );
//
//     _subscriptions[key] = subscription;
//     _controllers[key] = controller;
//
//     return controller.stream;
//   }
//
//   Stream<RealtimeEvent<Map<String, dynamic>>> subscribeCollectionRaw({
//     required String databaseId,
//     required String collectionId,
//   }) {
//     final channel = 'databases.$databaseId.collections.$collectionId.documents';
//     return subscribeRaw([channel]);
//   }
//
//   Stream<RealtimeEvent<T>> subscribeCollection<T>({
//     required String databaseId,
//     required String collectionId,
//     required T Function(Map<String, dynamic> json) fromJson,
//   }) {
//     final rawStream = subscribeCollectionRaw(
//       databaseId: databaseId,
//       collectionId: collectionId,
//     );
//
//     return rawStream.map((rawEvent) {
//       final data = rawEvent.data != null ? fromJson(rawEvent.data!) : null;
//
//       return RealtimeEvent<T>(
//         action: rawEvent.action,
//         raw: rawEvent.raw,
//         data: data,
//         documentId: rawEvent.documentId,
//         events: rawEvent.events,
//       );
//     });
//   }
//
//   void unsubscribe(List<String> channels) {
//     final key = _channelsKey(channels);
//
//     _subscriptions.remove(key)?.close();
//
//     final c = _controllers.remove(key);
//     if (c != null && !c.isClosed) {
//       c.close();
//     }
//   }
//
//   void unsubscribeCollection({
//     required String databaseId,
//     required String collectionId,
//   }) {
//     final channel = 'databases.$databaseId.collections.$collectionId.documents';
//     unsubscribe([channel]);
//   }
//
//   void dispose() {
//     for (final sub in _subscriptions.values) {
//       sub.close();
//     }
//     _subscriptions.clear();
//
//     for (final c in _controllers.values) {
//       if (!c.isClosed) c.close();
//     }
//     _controllers.clear();
//   }
// }


// lib/config/network/realtime_manager.dart

import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';

import 'appwrite_client.dart';

enum RealtimeAction {
  create,
  update,
  delete,
  unknown,
}

class RealtimeEvent<T> {
  final RealtimeAction action;
  final T? data;
  final String? documentId;
  final Map<String, dynamic> raw;
  final List<String> events; // ← اضافه شد برای fallback در delete

  RealtimeEvent({
    required this.action,
    required this.raw,
    required this.events,
    this.data,
    this.documentId,
  });

  @override
  String toString() {
    return 'RealtimeEvent(action: $action, documentId: $documentId, events: $events, data: $data)';
  }
}

class RealtimeManager {
  RealtimeManager._internal();
  static final RealtimeManager instance = RealtimeManager._internal();

  final Map<String, RealtimeSubscription> _subscriptions = {};
  final Map<String, StreamController<RealtimeEvent<Map<String, dynamic>>>>
  _controllers = {};

  Realtime get _realtime => AppwriteClient.instance.realtime;

  String _channelsKey(List<String> channels) => channels.join(',');

  /// استخراج action از events
  RealtimeAction _extractAction(List<String> events) {
    if (events.any((e) => e.endsWith('.create'))) return RealtimeAction.create;
    if (events.any((e) => e.endsWith('.update'))) return RealtimeAction.update;
    if (events.any((e) => e.endsWith('.delete'))) return RealtimeAction.delete;
    return RealtimeAction.unknown;
  }

  /// استخراج documentId از events (برای delete با payload خالی)
  String? _extractDocIdFromEvents(List<String> events) {
    for (final e in events) {
      final i = e.indexOf('.documents.');
      if (i == -1) continue;
      final tail = e.substring(i + '.documents.'.length);
      final dot = tail.indexOf('.');
      if (dot == -1) continue;
      final id = tail.substring(0, dot).trim();
      if (id.isNotEmpty) return id;
    }
    return null;
  }

  Stream<RealtimeEvent<Map<String, dynamic>>> subscribeRaw(List<String> channels) {
    final key = _channelsKey(channels);

    // اگر قبلاً ساخته شده، همان رو برگردون
    final existing = _controllers[key];
    if (existing != null && !existing.isClosed) {
      return existing.stream;
    }

    final controller =
    StreamController<RealtimeEvent<Map<String, dynamic>>>.broadcast();

    final subscription = _realtime.subscribe(channels);

    subscription.stream.listen(
          (RealtimeMessage message) {
        try {
          final events = List<String>.from(message.events);
          final action = _extractAction(events);

          // مدیریت امن payload — در delete معمولاً خالی یا null است
          Map<String, dynamic> payload = {};
          final rawPayload = message.payload;

          if (rawPayload is Map && rawPayload.isNotEmpty) {
            payload = Map<String, dynamic>.from(rawPayload);
          }

          // استخراج documentId
          String? documentId = payload[r'$id']?.toString() ??
              payload['\$id']?.toString() ??
              _extractDocIdFromEvents(events);

          documentId = documentId?.trim();

          // فقط اگر payload داده واقعی داشت، data بذار (در delete null باشه)
          final Map<String, dynamic>? data = payload.isNotEmpty ? payload : null;

          controller.add(
            RealtimeEvent<Map<String, dynamic>>(
              action: action,
              raw: payload,
              data: data,
              documentId: documentId,
              events: events,
            ),
          );
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint('RealtimeManager parse error: $e\n$st');
          }
        }
      },
      onError: (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('RealtimeManager connection error: $error\n$stackTrace');
        }
      },
      cancelOnError: false,
    );

    _subscriptions[key] = subscription;
    _controllers[key] = controller;

    return controller.stream;
  }

  Stream<RealtimeEvent<Map<String, dynamic>>> subscribeCollectionRaw({
    required String databaseId,
    required String collectionId,
  }) {
    final channel = 'databases.$databaseId.collections.$collectionId.documents';
    return subscribeRaw([channel]);
  }

  Stream<RealtimeEvent<T>> subscribeCollection<T>({
    required String databaseId,
    required String collectionId,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    final rawStream = subscribeCollectionRaw(
      databaseId: databaseId,
      collectionId: collectionId,
    );

    return rawStream.map((rawEvent) {
      final data = rawEvent.data != null ? fromJson(rawEvent.data!) : null;

      return RealtimeEvent<T>(
        action: rawEvent.action,
        raw: rawEvent.raw,
        data: data,
        documentId: rawEvent.documentId,
        events: rawEvent.events,
      );
    });
  }

  void unsubscribe(List<String> channels) {
    final key = _channelsKey(channels);
    _subscriptions.remove(key)?.close();
    final c = _controllers.remove(key);
    if (c != null && !c.isClosed) c.close();
  }

  void unsubscribeCollection({
    required String databaseId,
    required String collectionId,
  }) {
    final channel = 'databases.$databaseId.collections.$collectionId.documents';
    unsubscribe([channel]);
  }

  void dispose() {
    for (final sub in _subscriptions.values) {
      sub.close();
    }
    _subscriptions.clear();

    for (final c in _controllers.values) {
      if (!c.isClosed) c.close();
    }
    _controllers.clear();
  }
}