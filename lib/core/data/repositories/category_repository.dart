// consolidated repositories
import 'package:admin/services/http_services.dart';
import 'package:get/get.dart';


class BrandRepository {
  final HttpService _service = HttpService();
  Future<Response> fetchAll(String phone) {
    final endpoint = 'api/brands?phone_number_code=${Uri.encodeQueryComponent(phone)}&expand=subcategory';
    return _service.getItems(endpointUrl: endpoint);
  }
  Future<Response> addBrand(Map<String, dynamic> body) =>
      _service.addItem(endpointUrl: 'api/brands', itemData: body);
  Future<Response> updateBrand(String id, Map<String, dynamic> body) =>
      _service.updateItem(endpointUrl: 'api/brands', itemId: id, itemData: body);
  Future<Response> deleteBrand(String id) =>
      _service.deleteItem(endpointUrl: 'api/brands', itemId: id);
}

class SubCategoryRepository {
  final HttpService _service = HttpService();
  Future<Response> fetchAll(String phone) {
    final endpoint = 'api/subcategories?phone_number_code=${Uri.encodeQueryComponent(phone)}';
    return _service.getItems(endpointUrl: endpoint);
  }
  Future<Response> addSubCategory(Map<String, dynamic> body) =>
      _service.addItem(endpointUrl: 'api/subcategories', itemData: body);
  Future<Response> updateSubCategory(String id, Map<String, dynamic> body) =>
      _service.updateItem(endpointUrl: 'api/subcategories', itemId: id, itemData: body);
  Future<Response> deleteSubCategory(String id) =>
      _service.deleteItem(endpointUrl: 'api/subcategories', itemId: id);
}

class VariantTypeRepository {
  final HttpService _service = HttpService();
  Future<Response> fetchAll(String phone) {
    final endpoint = 'api/variant-types?phone_number_code=${Uri.encodeQueryComponent(phone)}';
    return _service.getItems(endpointUrl: endpoint);
  }
  Future<Response> addVariantType(Map<String, dynamic> body) =>
      _service.addItem(endpointUrl: 'api/variant-types', itemData: body);
  Future<Response> updateVariantType(String id, Map<String, dynamic> body) =>
      _service.updateItem(endpointUrl: 'api/variant-types', itemId: id, itemData: body);
  Future<Response> deleteVariantType(String id) =>
      _service.deleteItem(endpointUrl: 'api/variant-types', itemId: id);
}

class VariantRepository {
  final HttpService _service = HttpService();
  Future<Response> fetchAll(String phone) {
    final endpoint = 'api/variants?phone_number_code=${Uri.encodeQueryComponent(phone)}';
    return _service.getItems(endpointUrl: endpoint);
  }
  Future<Response> addVariant(Map<String, dynamic> body) =>
      _service.addItem(endpointUrl: 'api/variants', itemData: body);
  Future<Response> updateVariant(String id, Map<String, dynamic> body) =>
      _service.updateItem(endpointUrl: 'api/variants', itemId: id, itemData: body);
  Future<Response> deleteVariant(String id) =>
      _service.deleteItem(endpointUrl: 'api/variants', itemId: id);
}

class PosterRepository {
  final HttpService _service = HttpService();
  Future<Response> fetchAll(String phone) {
    final endpoint = 'api/posters?phone_number_code=${Uri.encodeQueryComponent(phone)}';
    return _service.getItems(endpointUrl: endpoint);
  }
  Future<Response> addPoster(FormData form) =>
      _service.addItem(endpointUrl: 'api/posters', itemData: form);
  Future<Response> updatePoster(String id, FormData form) =>
      _service.updateItem(endpointUrl: 'api/posters', itemId: id, itemData: form);
  Future<Response> deletePoster(String id) =>
      _service.deleteItem(endpointUrl: 'api/posters', itemId: id);
}

class ProductRepository {
  final HttpService _service = HttpService();
  Future<Response> fetchAll(String phone) {
    final endpoint = 'api/products?phone_number_code=${Uri.encodeQueryComponent(phone)}';
    return _service.getItems(endpointUrl: endpoint);
  }
  Future<Response> addProduct(FormData form) =>
      _service.addItem(endpointUrl: 'api/products', itemData: form);
  Future<Response> updateProduct(String id, FormData form) =>
      _service.updateItem(endpointUrl: 'api/products', itemId: id, itemData: form);
  Future<Response> deleteProduct(String id) =>
      _service.deleteItem(endpointUrl: 'api/products', itemId: id);
}

class CouponRepository {
  final HttpService _service = HttpService();
  Future<Response> fetchAll(String phone) {
    final endpoint = 'api/coupons?phone_number_code=${Uri.encodeQueryComponent(phone)}';
    return _service.getItems(endpointUrl: endpoint);
  }
  Future<Response> addCoupon(Map<String, dynamic> body) =>
      _service.addItem(endpointUrl: 'api/coupons', itemData: body);
  Future<Response> updateCoupon(String id, Map<String, dynamic> body) =>
      _service.updateItem(endpointUrl: 'api/coupons', itemId: id, itemData: body);
  Future<Response> deleteCoupon(String id) =>
      _service.deleteItem(endpointUrl: 'api/coupons', itemId: id);
}

class OrderRepository {
  final HttpService _service = HttpService();

  Future<Response> fetchAlls(String phone) {
    final endpoint = 'api/ordersalls?phone_number_code=${Uri.encodeQueryComponent(phone)}';
    return _service.getItems(endpointUrl: endpoint);
  }

  Future<Response> fetchPaged(String phone, {required int page, required int perPage}) {
    final endpoint = 'api/orders?phone_number_code=${Uri.encodeQueryComponent(phone)}&page=$page&perPage=$perPage';
    return _service.getItems(endpointUrl: endpoint);
  }

  Future<Response> updateOrder(String id, Map<String, dynamic> body) =>
      _service.updateItem(endpointUrl: 'api/orders', itemId: id, itemData: body);
  Future<Response> deleteOrder(String id) =>
      _service.deleteItem(endpointUrl: 'api/orders', itemId: id);
  Future<Response> updateStatus(String id, String status) =>
      _service.updateItem(endpointUrl: 'api/orders', itemId: id, itemData: {'orderStatus': status});
  Future<Response> updateTracking(String id, String trackingUrl) =>
      _service.updateItem(endpointUrl: 'api/orders', itemId: id, itemData: {'trackingUrl': trackingUrl});
}// lib/data/repositories/category_repository.dart



class CategoryRepository {
  final HttpService _service = HttpService();

  Future<Response> fetchAll(String phone) {
    final endpoint = 'api/categories?phone_number_code=${Uri.encodeQueryComponent(phone)}';
    return _service.getItems(endpointUrl: endpoint);
  }

  Future<Response> addCategory(FormData form) {
    return _service.addItem(endpointUrl: 'api/categories', itemData: form);
  }

  Future<Response> updateCategory(String id, FormData form) {
    return _service.updateItem(endpointUrl: 'api/categories', itemId: id, itemData: form);
  }

  Future<Response> deleteCategory(String id) {
    return _service.deleteItem(endpointUrl: 'api/categories', itemId: id);
  }
}