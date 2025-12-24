import 'dart:developer';

import 'package:admin/core/data/appwrite/orders_appwrite_service.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:admin/utility/User_helper.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/order.dart';

import '../../../utility/constants.dart';

import 'package:flutter/material.dart';

class OrderPaidProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final OrdersAppwriteService _ordersService;

  // فرم
  final orderFormKey = GlobalKey<FormState>();

  // وضعیت انتخاب‌شده برای آپدیت
  String selectedOrderStatus = ORDER_STATUS_PENDING;

  // سفارش انتخابی برای آپدیت
  Order? orderForUpdate;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  OrderPaidProvider(
      this._dataProvider, {
        OrdersAppwriteService? ordersService,
      }) : _ordersService = ordersService ?? OrdersAppwriteService();

  // ----------------------------
  // CRUD
  // ----------------------------

  /// آپدیت سفارش انتخاب‌شده (فعلاً فقط orderStatus)
  Future<bool> updateOrder() async {
    if (orderForUpdate == null) {
      SnackBarHelper.showErrorSnackBar('هیچ سفارشی برای بروزرسانی انتخاب نشده');
      return false;
    }
    final id = (orderForUpdate?.sId ?? '').trim();
    if (id.isEmpty) {
      SnackBarHelper.showErrorSnackBar('شناسه سفارش معتبر نیست');
      return false;
    }
    if (_isSubmitting) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      // اگر سشن/لاگینت expire میشه، اینجا هم چک کن
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد پیدا نشد!');
        return false;
      }

      await _ordersService.updateOrderDoc(id, {
        'orderStatus': selectedOrderStatus,
      });

      SnackBarHelper.showSuccessSnackBar('سفارش بروزرسانی شد');
      await _dataProvider.getAllsOrders(); // رفرش لیست
      resetForm();
      return true;
    } catch (e) {
      log('❌ Error updating order: $e');
      SnackBarHelper.showErrorSnackBar('خطا در بروزرسانی سفارش: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// حذف سفارش
  Future<bool> deleteOrder(Order order) async {
    final id = (order.sId ?? '').trim();
    if (id.isEmpty) {
      SnackBarHelper.showErrorSnackBar('شناسه سفارش معتبر نیست');
      return false;
    }

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد پیدا نشد!');
        return false;
      }

      await _ordersService.deleteOrderDoc(id);

      SnackBarHelper.showSuccessSnackBar('سفارش حذف شد');
      await _dataProvider.getAllsOrders(); // رفرش لیست
      return true;
    } catch (e) {
      log('❌ Delete order error: $e');
      SnackBarHelper.showErrorSnackBar('خطا در حذف سفارش: $e');
      return false;
    }
  }

  /// آپدیت سریع وضعیت (برای کانبان Drag&Drop)
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    final id = orderId.trim();
    if (id.isEmpty) return false;

    try {
      final phone = await UserSaveHelper.getPhoneNumber(showError: false) ?? '12345';
      if (phone.trim().isEmpty) {
        SnackBarHelper.showErrorSnackBar('شماره تلفن/کد پیدا نشد!');
        return false;
      }

      await _ordersService.updateStatus(id, newStatus);

      SnackBarHelper.showSuccessSnackBar('وضعیت سفارش تغییر کرد');
      await _dataProvider.getAllsOrders(); // رفرش لیست
      return true;
    } catch (e) {
      log('❌ Update order status error: $e');
      SnackBarHelper.showErrorSnackBar('خطا در تغییر وضعیت سفارش: $e');
      return false;
    }
  }



  // ----------------------------
  // UI helpers
  // ----------------------------

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
