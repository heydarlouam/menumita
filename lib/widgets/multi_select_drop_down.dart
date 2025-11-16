

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../utility/constants.dart';

class MultiSelectDropDown<T> extends StatelessWidget {
  final List<T> items;
  final Function(List<T>) onSelectionChanged;
  final String Function(T) displayItem;
  final List<T> selectedItems;

  const MultiSelectDropDown({
    Key? key,
    required this.items,
    required this.onSelectionChanged,
    required this.displayItem,
    required this.selectedItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontFamily: FONTS_STYLE_FAMILY, fontSize: 14);

    return Card(
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,

            // هینت داخل دکمه
            hint: Text(
              'انتخاب ایتم',
              style: textStyle.copyWith(color: Theme.of(context).hintColor),
            ),

            // آیتم‌های منو
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                enabled: false, // جلوگیری از بسته شدن منو
                child: StatefulBuilder(
                  builder: (context, menuSetState) {
                    final isSelected = selectedItems.contains(item);
                    return InkWell(
                      onTap: () {
                        isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                        onSelectionChanged(List<T>.from(selectedItems));
                        menuSetState(() {});
                      },
                      child: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                displayItem(item),
                                style: textStyle, // فونت آیتم‌ها
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),

            // مقدار انتخاب‌شده داخل دکمه (نمایش تَگ‌ها)
            value: selectedItems.isEmpty ? null : selectedItems.last,
            onChanged: (value) {},

            selectedItemBuilder: (context) {
              return items.map(
                    (item) {
                  return Container(
                    alignment: AlignmentDirectional.center,
                    child: Text(
                      selectedItems.map(displayItem).join(', '),
                      style: textStyle, // فونت مقدار انتخاب‌شده
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ).toList();
            },

            // استایل دکمه
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsetsDirectional.only(start: 16, end: 8), // RTL-aware
              height: 50,
              decoration: BoxDecoration(
                color: secondaryColor,
                border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
            ),

            // استایل منو/آیتم‌ها
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.zero,
            ),

            // جهت منو مطابق جهت متن (در RTL به سمت چپ باز می‌شود)
            dropdownStyleData: const DropdownStyleData(
              direction: DropdownDirection.textDirection,
            ),

            // آیکن پیش‌فرض هم مشکلی ندارد؛ اگر خواستی، می‌توان اضافه کرد.
          ),
        ),
      ),
    );
  }
}

