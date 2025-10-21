import 'package:flutter/material.dart';
import '../../../utility/constants.dart';

class ProductActionsBar extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onRefresh;
  final String title;

  const ProductActionsBar({
    super.key,
    required this.onAdd,
    required this.onRefresh,
    this.title = "محصولات من",
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final isCompact = c.maxWidth < 600; // موبایل جمع‌وجور
        return Padding(
          padding: const EdgeInsets.only(bottom: defaultPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: FONTS_STYLE_FAMILY,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

              ),
              // روی موبایل همون دکمه‌ها حفظ می‌شن (بدون تغییر استایل)
              ElevatedButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? defaultPadding : defaultPadding * 1.5,
                    vertical: defaultPadding,
                  ),
                ),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text("افزودن محصول",style: TextStyle(fontFamily: FONTS_STYLE_FAMILY),)
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: 'بروزرسانی محصولات',
                textStyle: const TextStyle(fontFamily: FONTS_STYLE_FAMILY, color: Colors.black),
                child: IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}
