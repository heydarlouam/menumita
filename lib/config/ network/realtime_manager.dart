// lib/config/network/realtime_manager.dart
import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/appwrite.dart' as appwrite_models;
import 'package:appwrite/models.dart' as appwrite_models;

import '../environment.dart';
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

  RealtimeEvent({
    required this.action,
    required this.raw,
    this.data,
    this.documentId,
  });
}

class RealtimeManager {
  RealtimeManager._internal();

  static final RealtimeManager instance = RealtimeManager._internal();

  final Map<String, appwrite_models.RealtimeSubscription> _subscriptions = {};
  final StreamController<RealtimeEvent<Map<String, dynamic>>> _rawController =
  StreamController<RealtimeEvent<Map<String, dynamic>>>.broadcast();

  Stream<RealtimeEvent<Map<String, dynamic>>> subscribeRaw(List<String> channels) {
    final realtime = AppwriteClient.instance.realtime;

    final key = channels.join(',');
    if (_subscriptions.containsKey(key)) {
      // قبلاً subscribe شده، فقط استریم را برمی‌گردانیم
      return _rawController.stream;
    }

    final sub = realtime.subscribe(channels);
    _subscriptions[key] = sub;

    sub.stream.listen((event) {
      final payload = Map<String, dynamic>.from(event.payload);
      final action = _mapEventToAction(event.events);

      final documentId = payload['\$id'] as String?;
      _rawController.add(
        RealtimeEvent<Map<String, dynamic>>(
          action: action,
          raw: payload,
          data: payload,
          documentId: documentId,
        ),
      );
    });

    return _rawController.stream;
  }

  /// Subscribe روی یک کالکشن مشخص از دیتابیس menumita
  Stream<RealtimeEvent<T>> subscribeCollection<T>({
    required String collectionId,
    required T Function(Map<String, dynamic>) fromJson,
    String? databaseId,
  }) {
    final dbId = databaseId ?? Environment.databaseIdMenuMita;

    final channel =
        'databases.$dbId.collections.$collectionId.documents';

    final rawStream = subscribeRaw([channel]);

    return rawStream.map((rawEvent) {
      final data = rawEvent.data;
      T? mapped;
      if (data != null) {
        mapped = fromJson(data);
      }

      return RealtimeEvent<T>(
        action: rawEvent.action,
        raw: rawEvent.raw,
        data: mapped,
        documentId: rawEvent.documentId,
      );
    });
  }

  void unsubscribeAll() {
    for (final sub in _subscriptions.values) {
      sub.close();
    }
    _subscriptions.clear();
  }

  void dispose() {
    unsubscribeAll();
    _rawController.close();
  }

  RealtimeAction _mapEventToAction(List<String> events) {
    // مثال events:
    // ['databases.*.collections.*.documents.*.create']
    final joined = events.join(',');
    if (joined.contains('.create')) {
      return RealtimeAction.create;
    }
    if (joined.contains('.update')) {
      return RealtimeAction.update;
    }
    if (joined.contains('.delete')) {
      return RealtimeAction.delete;
    }
    return RealtimeAction.unknown;
  }
}
