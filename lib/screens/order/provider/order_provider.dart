import 'dart:developer';


import 'package:admin/core/data/appwrite/orders_appwrite_service.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/order.dart';

import '../../../utility/constants.dart';


import 'package:appwrite/appwrite.dart';



class OrderProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final OrdersAppwriteService appwrite;

  final orderFormKey = GlobalKey<FormState>();
  String selectedOrderStatus = ORDER_STATUS_PENDING;
  Order? orderForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  OrderProvider(this._dataProvider, {OrdersAppwriteService? service})
      : appwrite = service ?? OrdersAppwriteService();

  Future<void> _refreshOrders() async {
    // اگر تو دیتاپرووایدر اسم متد فرق داره، همینجا عوضش کن
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
      final phone = await UserSaveHelper.getPhoneNumber();
      if (phone == null || phone.isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن در حافظه یافت نشد!');
        return false;
      }

      // ✅ آپدیت روی Appwrite
      await appwrite.updateOrder(
        orderForUpdate!.sId ?? '',
        {
          'orderStatus': selectedOrderStatus,
          // اگر لازم داری تو DB هم آپدیت بشه:
          'phone_number_code': phone,
          // 'trackingUrl': ... اگر داشتی
        },
      );

      SnackBarHelper.showSuccessSnackBar('سفارش با موفقیت بروزرسانی شد');
      await _refreshOrders();
      resetForm();
      return true;
    } on AppwriteException catch (e) {
      log('❌ Appwrite update error: ${e.message} (${e.code})');
      SnackBarHelper.showErrorSnackBar(e.message ?? 'خطا در بروزرسانی سفارش');
      return false;
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
      await appwrite.deleteOrder(order.sId ?? '');

      SnackBarHelper.showSuccessSnackBar('سفارش حذف شد');
      await _refreshOrders();
      return true;
    } on AppwriteException catch (e) {
      log('❌ Appwrite delete error: ${e.message} (${e.code})');
      SnackBarHelper.showErrorSnackBar(e.message ?? 'خطا در حذف سفارش');
      return false;
    } catch (e) {
      log('❌ Delete order error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred while deleting order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // ✅ آپدیت روی Appwrite
      await appwrite.updateOrderStatus(orderId, newStatus);

      SnackBarHelper.showSuccessSnackBar('وضعیت سفارش بروزرسانی شد');
      await _refreshOrders();
      return true;
    } on AppwriteException catch (e) {
      log('❌ Appwrite status update error: ${e.message} (${e.code})');
      SnackBarHelper.showErrorSnackBar(e.message ?? 'خطا در بروزرسانی وضعیت');
      return false;
    } catch (e) {
      log('❌ Update order status error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  Future<bool> updateTrackingUrl(String orderId, String trackingUrl) async {
    try {
      await appwrite.updateTrackingUrl(orderId, trackingUrl);

      SnackBarHelper.showSuccessSnackBar('لینک پیگیری بروزرسانی شد');
      await _refreshOrders();
      return true;
    } on AppwriteException catch (e) {
      log('❌ Appwrite tracking update error: ${e.message} (${e.code})');
      SnackBarHelper.showErrorSnackBar(e.message ?? 'خطا در بروزرسانی لینک پیگیری');
      return false;
    } catch (e) {
      log('❌ Update tracking URL error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  void loadOrderForUpdate(Order order) {
    orderForUpdate = order;
    selectedOrderStatus = order.orderStatus ?? ORDER_STATUS_PENDING;
    notifyListeners();
  }

  void resetForm() {
    orderForUpdate = null;
    selectedOrderStatus = ORDER_STATUS_PENDING;
    notifyListeners();
  }

  void updateUI() => notifyListeners();
}
