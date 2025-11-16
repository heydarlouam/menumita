import 'dart:developer';


import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/order.dart';
import '../../../core/data/repositories/category_repository.dart';
import '../../../utility/constants.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository repository = OrderRepository();
  final DataProvider _dataProvider;

  final orderFormKey = GlobalKey<FormState>();
  final TextEditingController trackingUrlCtrl = TextEditingController();
  String selectedOrderStatus = ORDER_STATUS_PENDING;
  Order? orderForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  OrderProvider(this._dataProvider);

  @override
  void dispose() {
    trackingUrlCtrl.dispose();
    super.dispose();
  }

  /// ✅ متد مشترک برای رفرش لیست سفارش‌ها بعد از هر تغییر
  Future<void> _refreshOrders() async {
    await _dataProvider.loadInitialOrders(showSnack: true);

    notifyListeners();
  }
  Future<bool> updateOrder() async {
    if (orderForUpdate == null) {
      SnackBarHelper.showErrorSnackBar('No order selected for update');
      return false;
    }
    if (_isSubmitting) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      final order = {
        'trackingUrl': trackingUrlCtrl.text,
        'orderStatus': selectedOrderStatus,
      };

      final response = await repository.updateOrder(
        orderForUpdate?.sId ?? '',
        order,
      );

      if (response.isOk && response.body['success'] == true) {
        SnackBarHelper.showSuccessSnackBar(
            response.body['message'] ?? 'Order updated successfully');
        await _refreshOrders(); // ✅ رفرش بعد از حذف
        resetForm();
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to update order: ${response.body?['message'] ?? response.statusText}');
        return false;
      }
    } catch (e) {
      log('❌ Error updating order: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOrder(Order order) async {
    try {
      final response = await repository.deleteOrder(
        order.sId ?? '',
      );

      if (response.isOk && response.body['success'] == true) {
        SnackBarHelper.showSuccessSnackBar(
            response.body['message'] ?? 'Order deleted successfully!');
        await _refreshOrders(); // ✅ رفرش بعد از حذف
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to delete order: ${response.body?['message'] ?? response.statusText}');
        return false;
      }
    } catch (e) {
      log('❌ Delete order error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred while deleting order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await repository.updateStatus(orderId, newStatus);

      if (response.isOk && response.body['success'] == true) {
        SnackBarHelper.showSuccessSnackBar('Order status updated to $newStatus');
        await _refreshOrders(); // ✅ رفرش بعد از حذف
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to update order status: ${response.body?['message'] ?? response.statusText}');
        return false;
      }


    } catch (e) {
      log('❌ Update order status error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateTrackingUrl(String orderId, String trackingUrl) async {
    try {
      final response = await repository.updateTracking(orderId, trackingUrl);

      if (response.isOk && response.body['success'] == true) {
        SnackBarHelper.showSuccessSnackBar('Tracking URL updated');
        await _refreshOrders(); // ✅ رفرش بعد از حذف
        return true;
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Failed to update tracking URL: ${response.body?['message'] ?? response.statusText}');
        return false;
      }
    } catch (e) {
      log('❌ Update tracking URL error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  void loadOrderForUpdate(Order order) {
    orderForUpdate = order;
    trackingUrlCtrl.text = order.trackingUrl ?? '';
    selectedOrderStatus = order.orderStatus ?? ORDER_STATUS_PENDING;
    notifyListeners();
  }

  void resetForm() {
    orderForUpdate = null;
    trackingUrlCtrl.clear();
    selectedOrderStatus = ORDER_STATUS_PENDING;
    notifyListeners();
  }

  void updateUI() => notifyListeners();
}
