import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utility/constants.dart';
import '../../widgets/custom_dropdown.dart';
import 'components/order_header.dart';
import 'components/order_list_section.dart';


class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            OrderHeader(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              "My Orders",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Gap(20),
                          SizedBox(
                            width: 280,
                            child: CustomDropdown(
                              hintText: 'Filter Order By status',
                              initialValue: ORDER_STATUS_ALL,
                              items: [
                                ORDER_STATUS_ALL,
                                ORDER_STATUS_PENDING,
                                ORDER_STATUS_PROCESSING,
                                ORDER_STATUS_SHIPPED,
                                ORDER_STATUS_DELIVERED,
                                ORDER_STATUS_CANCELLED
                              ],
                              displayItem: (val) => _getStatusDisplayName(val),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  print('Filtering by: $newValue'); // برای دیباگ
                                  context.dataProvider.filterOrders(newValue);
                                }
                              },
                              validator: (value) {
                                return null;
                              },
                            ),
                          ),
                          Gap(40),
                          IconButton(
                            onPressed: () {
                              context.dataProvider.getAllOrders(showSnack: true);
                              // ریست کردن فیلتر
                              context.dataProvider.filterOrders(ORDER_STATUS_ALL);
                            },
                            icon: Icon(Icons.refresh),
                            tooltip: 'Refresh and reset filters',
                          ),
                        ],
                      ),
                      Gap(defaultPadding),
                      OrderListSection(),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // تابع برای نمایش نام زیباتر status
  String _getStatusDisplayName(String status) {
    switch (status) {
      case ORDER_STATUS_ALL:
        return 'All Orders';
      case ORDER_STATUS_PENDING:
        return 'Pending';
      case ORDER_STATUS_PROCESSING:
        return 'Processing';
      case ORDER_STATUS_SHIPPED:
        return 'Shipped';
      case ORDER_STATUS_DELIVERED:
        return 'Delivered';
      case ORDER_STATUS_CANCELLED:
        return 'Cancelled';
      default:
        return status;
    }
  }
}