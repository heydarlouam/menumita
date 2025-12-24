// lib/config/network/appwrite_client.dart
import 'package:appwrite/appwrite.dart';
import '../environment.dart';

/// Singleton برای نگه‌داری Client / سرویس‌ها در کل اپ.
class AppwriteClient {
  AppwriteClient._internal();

  static final AppwriteClient instance = AppwriteClient._internal();

  Client? _client;
  Databases? _databases;
  Realtime? _realtime;
  Account? _account;
  Storage? _storage;
  Functions? _functions;

  bool get isInitialized => _client != null;

  /// حتماً در main() قبل از runApp صدا زده شود.
  ///
  /// برای سازگاری با پروژه، پارامترها اختیاری هستند و اگر ندهید از Environment استفاده می‌شود.
  void init({
    String? endpoint,
    String? projectId,
    bool selfSigned = false,
  }) {
    if (isInitialized) return;

    final client = Client()
      ..setEndpoint(endpoint ?? Environment.appwriteEndpoint)
      ..setProject(projectId ?? Environment.appwriteProjectId);

    if (selfSigned) {
      client.setSelfSigned(status: true);
    }

    _client = client;
    _databases = Databases(client);
    _realtime = Realtime(client);
    _account = Account(client);
    _storage = Storage(client);
    _functions = Functions(client);
  }

  Client get client {
    final c = _client;
    if (c == null) {
      throw StateError(
        'AppwriteClient هنوز init نشده. قبل از استفاده، AppwriteClient.instance.init() را صدا بزن.',
      );
    }
    return c;
  }

  Databases get databases {
    final d = _databases;
    if (d == null) {
      throw StateError(
        'AppwriteClient هنوز init نشده. Databases مقداردهی نشده است.',
      );
    }
    return d;
  }

  Realtime get realtime {
    final r = _realtime;
    if (r == null) {
      throw StateError(
        'AppwriteClient هنوز init نشده. Realtime مقداردهی نشده است.',
      );
    }
    return r;
  }

  Account get account {
    final a = _account;
    if (a == null) {
      throw StateError(
        'AppwriteClient هنوز init نشده. Account مقداردهی نشده است.',
      );
    }
    return a;
  }

  Storage get storage {
    final s = _storage;
    if (s == null) {
      throw StateError(
        'AppwriteClient هنوز init نشده. Storage مقداردهی نشده است.',
      );
    }
    return s;
  }

  Functions get functions {
    final f = _functions;
    if (f == null) {
      throw StateError(
        'AppwriteClient هنوز init نشده. Functions مقداردهی نشده است.',
      );
    }
    return f;
  }

  void setJWT(String jwt) => client.setJWT(jwt);

  void setSession(String sessionId) => client.setSession(sessionId);

  /// ریست ساده‌ی auth بدون دست‌زدن به client
  void resetAuth() {
    client.setJWT('');
    client.setSession('');
  }

  /// اگر لازم شد کل کلاینت و سرویس‌ها را ریست کنی (مثلاً تغییر endpoint)
  void resetAll() {
    _client = null;
    _databases = null;
    _realtime = null;
    _account = null;
    _storage = null;
    _functions = null;
  }
}
