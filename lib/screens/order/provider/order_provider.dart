import 'dart:developer';


import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/get.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/order.dart';
import '../../../services/http_services.dart';
import '../../../utility/constants.dart';

// class OrderProvider extends ChangeNotifier {
//   HttpService service = HttpService();
//   final DataProvider _dataProvider;
//   final orderFormKey = GlobalKey<FormState>();
//   TextEditingController trackingUrlCtrl = TextEditingController();
//   String selectedOrderStatus = ORDER_STATUS_PENDING;
//   Order? orderForUpdate;
//
//   OrderProvider(this._dataProvider);
//
//   updateOrder() async {
//     try {
//       if (orderForUpdate != null) {
//         Map<String, dynamic> order = {
//           'trackingUrl': trackingUrlCtrl.text,
//           'orderStatus': selectedOrderStatus
//         };
//
//         final response = await service.updateItem(
//             endpointUrl: 'orders',
//             itemId: orderForUpdate?.sId ?? '',
//             itemData: order);
//
//         if (response.isOk) {
//           ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
//
//           if (apiResponse.success == true) {
//             SnackBarHelper.showSuccessSnackBar(apiResponse.message);
//             log('order updated');
//             _dataProvider.getAllOrders();
//           } else {
//             SnackBarHelper.showErrorSnackBar(
//                 'Failed to update order: ${apiResponse.message}');
//           }
//         } else {
//           SnackBarHelper.showErrorSnackBar(
//               'Error: ${response.body?['message'] ?? response.statusText}');
//         }
//       }
//     } catch (e) {
//       log(e.toString());
//       SnackBarHelper.showErrorSnackBar('An error occurred: $e');
//       rethrow;
//     }
//   }
//
//   deleteOrder(Order order) async {
//     try {
//       Response response = await service.deleteItem(
//           endpointUrl: 'orders', itemId: order.sId ?? '');
//
//       if (response.isOk) {
//         ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
//
//         if (apiResponse.success == true) {
//           SnackBarHelper.showSuccessSnackBar('Order deleted successfully!');
//           _dataProvider.getAllOrders();
//         }
//       } else {
//         SnackBarHelper.showErrorSnackBar(
//             'Error: ${response.body?['message'] ?? response.statusText}');
//       }
//     } catch (e) {
//       print(e);
//       rethrow;
//     }
//   }
//
//   updateUI() {
//     notifyListeners();
//   }
// }


import 'dart:developer';

import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/order.dart';
import '../../../services/http_services.dart';
import '../../../utility/constants.dart';

class OrderProvider extends ChangeNotifier {
  HttpService service = HttpService();
  final DataProvider _dataProvider;
  final orderFormKey = GlobalKey<FormState>();
  TextEditingController trackingUrlCtrl = TextEditingController();
  String selectedOrderStatus = ORDER_STATUS_PENDING;
  Order? orderForUpdate;

  OrderProvider(this._dataProvider);

  updateOrder() async {
    try {
      if (orderForUpdate != null) {
        Map<String, dynamic> order = {
          'trackingUrl': trackingUrlCtrl.text,
          'orderStatus': selectedOrderStatus
        };

        // 🔥 اصلاح: استفاده از endpoint صحیح برای PocketBase
        final response = await service.updateItem(
            endpointUrl: 'api/orders', // ✅ اضافه کردن api/
            itemId: orderForUpdate?.sId ?? '',
            itemData: order);

        if (response.isOk) {
          final responseBody = response.body;

          if (responseBody['success'] == true) {
            SnackBarHelper.showSuccessSnackBar(
                responseBody['message'] ?? 'Order updated successfully');
            log('✅ Order updated successfully');
            _dataProvider.getAllOrders();

            // ریست کردن فرم
            trackingUrlCtrl.clear();
            selectedOrderStatus = ORDER_STATUS_PENDING;
            orderForUpdate = null;
          } else {
            SnackBarHelper.showErrorSnackBar(
                'Failed to update order: ${responseBody['message']}');
          }
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Error: ${response.body?['message'] ?? response.statusText}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar('No order selected for update');
      }
    } catch (e) {
      log('❌ Error updating order: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  deleteOrder(Order order) async {
    try {
      // 🔥 اصلاح: استفاده از endpoint صحیح برای PocketBase
      Response response = await service.deleteItem(
          endpointUrl: 'api/orders', // ✅ اضافه کردن api/
          itemId: order.sId ?? '');

      if (response.isOk) {
        final responseBody = response.body;

        if (responseBody['success'] == true) {
          SnackBarHelper.showSuccessSnackBar(
              responseBody['message'] ?? 'Order deleted successfully!');
          _dataProvider.getAllOrders();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to delete order: ${responseBody['message']}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print('❌ Delete order error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred while deleting order: $e');
      rethrow;
    }
  }

  // 🔥 متد جدید برای آپدیت سریع وضعیت سفارش
  updateOrderStatus(String orderId, String newStatus) async {
    try {
      Map<String, dynamic> updateData = {
        'orderStatus': newStatus
      };

      final response = await service.updateItem(
          endpointUrl: 'api/orders',
          itemId: orderId,
          itemData: updateData);

      if (response.isOk) {
        final responseBody = response.body;

        if (responseBody['success'] == true) {
          SnackBarHelper.showSuccessSnackBar('Order status updated to $newStatus');
          _dataProvider.getAllOrders();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update order status: ${responseBody['message']}');
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['message'] ?? response.statusText}');
        return false;
      }
    } catch (e) {
      log('❌ Update order status error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  // 🔥 متد برای آپدیت tracking URL
  updateTrackingUrl(String orderId, String trackingUrl) async {
    try {
      Map<String, dynamic> updateData = {
        'trackingUrl': trackingUrl
      };

      final response = await service.updateItem(
          endpointUrl: 'api/orders',
          itemId: orderId,
          itemData: updateData);

      if (response.isOk) {
        final responseBody = response.body;

        if (responseBody['success'] == true) {
          SnackBarHelper.showSuccessSnackBar('Tracking URL updated');
          _dataProvider.getAllOrders();
          return true;
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update tracking URL: ${responseBody['message']}');
          return false;
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['message'] ?? response.statusText}');
        return false;
      }
    } catch (e) {
      log('❌ Update tracking URL error: $e');
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      return false;
    }
  }

  // 🔥 متد برای بارگذاری اطلاعات سفارش برای ویرایش
  loadOrderForUpdate(Order order) {
    orderForUpdate = order;
    trackingUrlCtrl.text = order.trackingUrl ?? '';
    selectedOrderStatus = order.orderStatus ?? ORDER_STATUS_PENDING;
    notifyListeners();
  }

  // 🔥 متد برای ریست کردن فرم
  resetForm() {
    orderForUpdate = null;
    trackingUrlCtrl.clear();
    selectedOrderStatus = ORDER_STATUS_PENDING;
    notifyListeners();
  }

  updateUI() {
    notifyListeners();
  }
}