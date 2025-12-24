import 'package:admin/config/environment.dart';
import 'package:appwrite/appwrite.dart';
import 'package:admin/models/order.dart';
import 'package:appwrite/models.dart';

class OrdersPageResult {
  final List<Order> orders;
  final bool hasMore;
  final int total;

  const OrdersPageResult({
    required this.orders,
    required this.hasMore,
    required this.total,
  });
}

class OrdersAppwriteService {
  final Client _client;
  final Databases db;
  final Realtime realtime;

  final String databaseId;
  final String ordersCollectionId;

  OrdersAppwriteService({
    Client? client,
    String endpoint = Environment.appwriteEndpoint,
    String projectId = Environment.appwriteProjectId,
    this.databaseId = Environment.databaseIdMenuMita,
    this.ordersCollectionId = Environment.collectionIdOrders,
  })  : _client = client ??
      (Client()
        ..setEndpoint(endpoint)
        ..setProject(projectId)),
        db = Databases(client ??
            (Client()
              ..setEndpoint(endpoint)
              ..setProject(projectId))),
        realtime = Realtime(client ??
            (Client()
              ..setEndpoint(endpoint)
              ..setProject(projectId))) {
    // ✅ اگر می‌خوای فقط یک Client استفاده بشه (پیشنهادی)،
    // سازنده‌ی بالا رو اینطوری کن:
    //
    // }) : _client = client ?? (Client()..setEndpoint(endpoint)..setProject(projectId)),
    //      db = Databases(_client),
    //      realtime = Realtime(_client);
    //
    // چون الان اگر client پاس ندی، 3 تا Client جدا ساخته میشه.
  }


  // ----------- helpers -----------
  Map<String, dynamic> _normalizeDoc(Map<String, dynamic> doc) {
    final m = Map<String, dynamic>.from(doc);
    m['id'] ??= m[r'$id'];
    m['created'] ??= m[r'$createdAt'];
    return m;
  }

  Order _mapDocToOrder(Map<String, dynamic> doc) {
    final normalized = _normalizeDoc(doc);
    return Order.fromJson(normalized);
  }

  // ----------- Realtime -----------
  RealtimeSubscription subscribeOrders(void Function(RealtimeMessage msg) onMessage) {
    final sub = realtime.subscribe([
      'databases.$databaseId.collections.$ordersCollectionId.documents',
    ]);
    sub.stream.listen(onMessage);
    return sub;
  }

  // ----------- Fetch (ALL InProgress) -----------
  Future<List<Order>> fetchAllInProgress({
    required String phoneNumberCode,
    int batchSize = 200,
  }) async {
    final all = <Order>[];
    int offset = 0;
    int total = 1 << 30;

    while (all.length < total) {
      final res = await db.listDocuments(
        databaseId: databaseId,
        collectionId: ordersCollectionId,
        queries: [
          Query.equal('phone_number_code', phoneNumberCode),
          Query.notEqual('orderStatus', 'Paid'),
          Query.notEqual('orderStatus', 'paid'),
          Query.orderDesc(r'$createdAt'),
          Query.limit(batchSize),
          Query.offset(offset),
        ],
      );

      total = res.total;
      final docs = res.documents;
      all.addAll(docs.map((d) => _mapDocToOrder(d.data)));

      if (docs.length < batchSize) break;
      offset += batchSize;
    }

    return all;
  }

  // ----------- Fetch (Paid Paged) -----------
  Future<OrdersPageResult> fetchPaidPaged({
    required String phoneNumberCode,
    required int page,
    required int perPage,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final offset = (safePage - 1) * perPage;

    final res = await db.listDocuments(
      databaseId: databaseId,
      collectionId: ordersCollectionId,
      queries: [
        Query.equal('phone_number_code', phoneNumberCode),
        Query.equal('orderStatus', 'Paid'),
        Query.orderDesc(r'$createdAt'),
        Query.limit(perPage),
        Query.offset(offset),
      ],
    );

    final orders = res.documents.map((d) => _mapDocToOrder(d.data)).toList();
    final hasMore = offset + orders.length < res.total;

    return OrdersPageResult(orders: orders, hasMore: hasMore, total: res.total);
  }

  // =========================
  // ✅ UPDATE / DELETE (Appwrite)
  // =========================

  Future<Order> updateOrder(String documentId, Map<String, dynamic> data) async {
    final Document doc = await db.updateDocument(
      databaseId: databaseId,
      collectionId: ordersCollectionId,
      documentId: documentId,
      data: data,
    );
    return _mapDocToOrder(doc.data);
  }

  Future<void> deleteOrder(String documentId) async {
    await db.deleteDocument(
      databaseId: databaseId,
      collectionId: ordersCollectionId,
      documentId: documentId,
    );
  }

  Future<Order> updateOrderStatus(String documentId, String newStatus) {
    return updateOrder(documentId, {'orderStatus': newStatus});
  }

  Future<Order> updateTrackingUrl(String documentId, String trackingUrl) {
    return updateOrder(documentId, {'trackingUrl': trackingUrl});
  }
  // ----------------- helpers -----------------
  Map<String, dynamic> _normalizeDocMap(Map<String, dynamic> doc) {
    final m = Map<String, dynamic>.from(doc);
    m['id'] ??= m[r'$id'];
    m['created'] ??= m[r'$createdAt'];
    return m;
  }

  Map<String, dynamic> _docToJsonWithMeta(Document doc) {
    final m = <String, dynamic>{};
    m.addAll(doc.data);

    // اگر متا داخل data نبود، اضافه کن
    m[r'$id'] ??= doc.$id;
    m[r'$createdAt'] ??= doc.$createdAt;
    m[r'$updatedAt'] ??= doc.$updatedAt;

    // برای سازگاری با جاهای قدیمی
    m['id'] ??= doc.$id;
    m['created'] ??= doc.$createdAt;

    return m;
  }

  Order _mapDocToOrderFromDocument(Document doc) {
    final json = _normalizeDocMap(_docToJsonWithMeta(doc));
    return Order.fromJson(json);
  }

  // ----------------- Realtime -----------------
  // RealtimeSubscription subscribeOrders(void Function(RealtimeMessage msg) onMessage) {
  //   final sub = realtime.subscribe([
  //     'databases.$databaseId.collections.$ordersCollectionId.documents',
  //   ]);
  //   sub.stream.listen(onMessage);
  //   return sub;
  // }
  //
  // // ----------------- READ: In Progress (ALL, no pagination) -----------------
  // /// ✅ همه سفارشات به جز Paid (برای داشبورد / سفارشات در جریان)
  // Future<List<Order>> fetchAllInProgress({
  //   required String phoneNumberCode,
  //   int batchSize = 200,
  // }) async {
  //   final all = <Order>[];
  //   int offset = 0;
  //   int total = 1 << 30;
  //
  //   while (all.length < total) {
  //     final res = await db.listDocuments(
  //       databaseId: databaseId,
  //       collectionId: ordersCollectionId,
  //       queries: [
  //         Query.equal('phone_number_code', phoneNumberCode),
  //         Query.notEqual('orderStatus', 'Paid'),
  //         Query.notEqual('orderStatus', 'paid'),
  //         Query.orderDesc(r'$createdAt'),
  //         Query.limit(batchSize),
  //         Query.offset(offset),
  //       ],
  //     );
  //
  //     total = res.total;
  //     final docs = res.documents;
  //
  //     all.addAll(docs.map(_mapDocToOrderFromDocument));
  //
  //     if (docs.length < batchSize) break;
  //     offset += batchSize;
  //   }
  //
  //   return all;
  // }
  //
  // // ----------------- READ: Paid Orders (PAGINATION) -----------------
  // /// ✅ فقط Paid ها با پیجین
  // Future<OrdersPageResult> fetchPaidPaged({
  //   required String phoneNumberCode,
  //   required int page,
  //   required int perPage,
  // }) async {
  //   final safePage = page < 1 ? 1 : page;
  //   final offset = (safePage - 1) * perPage;
  //
  //   final res = await db.listDocuments(
  //     databaseId: databaseId,
  //     collectionId: ordersCollectionId,
  //     queries: [
  //       Query.equal('phone_number_code', phoneNumberCode),
  //       Query.equal('orderStatus', 'Paid'),
  //       Query.orderDesc(r'$createdAt'),
  //       Query.limit(perPage),
  //       Query.offset(offset),
  //     ],
  //   );
  //
  //   final orders = res.documents.map(_mapDocToOrderFromDocument).toList();
  //   final hasMore = offset + orders.length < res.total;
  //
  //   return OrdersPageResult(orders: orders, hasMore: hasMore, total: res.total);
  // }

  // ----------------- ✅ UPDATE / DELETE -----------------
  Future<Order> updateOrderDoc(String id, Map<String, dynamic> data) async {
    final clean = Map<String, dynamic>.from(data)..removeWhere((k, v) => v == null);

    final res = await db.updateDocument(
      databaseId: databaseId,
      collectionId: ordersCollectionId,
      documentId: id,
      data: clean,
    );

    return _mapDocToOrderFromDocument(res);
  }

  Future<void> deleteOrderDoc(String id) async {
    await db.deleteDocument(
      databaseId: databaseId,
      collectionId: ordersCollectionId,
      documentId: id,
    );
  }

  Future<Order> updateStatus(String id, String status) {
    return updateOrderDoc(id, {'orderStatus': status});
  }

  Future<Order> updateTracking(String id, String trackingUrl) {
    return updateOrderDoc(id, {'trackingUrl': trackingUrl});
  }
}
