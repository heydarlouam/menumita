// lib/config/network/appwrite_client.dart
import 'package:appwrite/appwrite.dart';
import '../environment.dart';

// class AppwriteClient {
//   AppwriteClient._internal();
//
//   static final AppwriteClient instance = AppwriteClient._internal();
//
//   Client? _client;
//   Databases? _databases;
//   Realtime? _realtime;
//   Account? _account;
//   late final Storage storage = Storage(client);
//   Client get client {
//     final c = _client;
//     if (c == null) {
//       throw StateError(
//         'AppwriteClient is not initialized. Call AppwriteClient.instance.init() in main() before using it.',
//       );
//     }
//     return c;
//   }
//
//   Databases get databases {
//     final db = _databases;
//     if (db == null) {
//       throw StateError(
//         'AppwriteClient is not initialized. Databases is null.',
//       );
//     }
//     return db;
//   }
//
//   Realtime get realtime {
//     final rt = _realtime;
//     if (rt == null) {
//       throw StateError(
//         'AppwriteClient is not initialized. Realtime is null.',
//       );
//     }
//     return rt;
//   }
//
//   Account get account {
//     final acc = _account;
//     if (acc == null) {
//       throw StateError(
//         'AppwriteClient is not initialized. Account is null.',
//       );
//     }
//     return acc;
//   }
//
//   /// حتماً در main() قبل از runApp صدا زده شود.
//   void init() {
//     final c = Client()
//         .setEndpoint(Environment.appwriteEndpoint)
//         .setProject(Environment.appwriteProjectId);
//
//     _client = c;
//     _databases = Databases(c);
//     _realtime = Realtime(c);
//     _account = Account(c);
//   }
//
//   /// در صورت استفاده از JWT (مثلاً برای پنل ادمین)
//   void setJWT(String jwt) {
//     client.setJWT(jwt);
//   }
//
//   /// در صورت استفاده از Session ID (کلاینت نیتیو)
//   void setSession(String sessionId) {
//     client.setSession(sessionId);
//   }
//
//   /// لاگ‌اوت / ریست احراز هویت
//   void resetAuth() {
//     // با توجه به نوع auth که استفاده می‌کنی، این متد رو می‌تونی گسترش بدی
//     client.setJWT('');
//     client.setSession('');
//   }
// }

import 'package:appwrite/appwrite.dart';
import '../environment.dart';

class AppwriteClient {
  AppwriteClient._internal();

  static final AppwriteClient instance = AppwriteClient._internal();

  Client? _client;
  Databases? _databases;
  Realtime? _realtime;
  Account? _account;
  Storage? _storage;

  Client get client {
    final c = _client;
    if (c == null) {
      throw StateError(
        'AppwriteClient is not initialized. Call AppwriteClient.instance.init() in main() before using it.',
      );
    }
    return c;
  }

  Databases get databases {
    final db = _databases;
    if (db == null) {
      throw StateError('AppwriteClient is not initialized. Databases is null.');
    }
    return db;
  }

  Realtime get realtime {
    final rt = _realtime;
    if (rt == null) {
      throw StateError('AppwriteClient is not initialized. Realtime is null.');
    }
    return rt;
  }

  Account get account {
    final acc = _account;
    if (acc == null) {
      throw StateError('AppwriteClient is not initialized. Account is null.');
    }
    return acc;
  }

  // ✅ این getter رو اضافه/یکدست کن
  Storage get storage {
    final s = _storage;
    if (s == null) {
      throw StateError('AppwriteClient is not initialized. Storage is null.');
    }
    return s;
  }

  /// حتماً در main() قبل از runApp صدا زده شود.
  void init() {
    final c = Client()
        .setEndpoint(Environment.appwriteEndpoint)
        .setProject(Environment.appwriteProjectId);

    _client = c;
    _databases = Databases(c);
    _realtime = Realtime(c);
    _account = Account(c);
    _storage = Storage(c); // ✅ اینجا مقداردهی شد
  }

  void setJWT(String jwt) => client.setJWT(jwt);

  void setSession(String sessionId) => client.setSession(sessionId);

  void resetAuth() {
    client.setJWT('');
    client.setSession('');
  }
}
