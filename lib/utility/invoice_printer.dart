//
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
//
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// import '../models/order.dart';
// import '../utility/User_helper.dart';
// import '../utility/functions.dart'; // money(ctx, ...)
// import '../utility/snack_bar_helper.dart';
//
// class InvoicePrinter {
//   static pw.Font? _font;
//
//   static Future<pw.Font> _loadFont() async {
//     if (_font != null) return _font!;
//     final data = await rootBundle.load('assets/fonts/dm.ttf');
//     _font = pw.Font.ttf(data);
//     return _font!;
//   }
//
//   static Future<void> printInvoice(BuildContext context, Order order) async {
//     try {
//       final pdfBytes = await _buildPdf(context, order);
//       await Printing.layoutPdf(
//         onLayout: (_) async => pdfBytes,
//         name: 'invoice_${order.sId ?? ''}.pdf',
//       );
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('خطا در چاپ فاکتور: $e');
//     }
//   }
//
//   static Future<void> previewInvoice(BuildContext context, Order order) async {
//     try {
//       await showDialog(
//         context: context,
//         builder: (_) => Dialog(
//           child: LayoutBuilder(
//             builder: (ctx, c) => SizedBox(
//               width: c.maxWidth.clamp(320, 980),
//               height: c.maxHeight.clamp(420, 780),
//               child: PdfPreview(
//                 build: (format) => _buildPdf(context, order, pageFormat: format),
//                 canChangePageFormat: true,
//                 canChangeOrientation: false,
//                 pdfFileName: 'invoice_${order.sId ?? ''}.pdf',
//               ),
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('خطا در پیش‌نمایش فاکتور: $e');
//     }
//   }
//
//   static Future<Uint8List> _buildPdf(
//       BuildContext context,
//       Order order, {
//         PdfPageFormat? pageFormat,
//       }) async {
//     final font = await _loadFont();
//
//     // ✅ fallback برای لاتین/علائم (@ . - , ...)
//     final fallback1 = pw.Font.helvetica();
//     final fallback2 = pw.Font.helveticaBold();
//
//     pw.TextStyle t(
//         double size, {
//           bool bold = false,
//           PdfColor? color,
//         }) =>
//         pw.TextStyle(
//           font: font,
//           fontFallback: [fallback1, fallback2],
//           fontSize: size,
//           fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: color ?? PdfColors.black,
//           lineSpacing: 2,
//         );
//
//     String s(dynamic v) => (v ?? '').toString().trim();
//     String dashIfEmpty(String v) => v.isEmpty ? '-' : v;
//
//     // ✅ فیکس خطای num -> double
//     String moneySafe(num? n) => money(context, (n ?? 0).toDouble());
//
//
//     // ✅ داخل آیتم‌ها «ریال» حذف شود
//     String moneyItems(num? n) {
//       final txt = moneySafe(n);
//       // هر حالتی از "ریال" + فاصله‌ها
//       return txt.replaceAll('ریال', '').replaceAll('  ', ' ').trim();
//     }
//     final shop = await UserSaveHelper.getUserInfo(showError: false) ?? {};
//     final logoUrl = s(shop['icon_logo_url']);
//     final shopName = s(shop['name_bizi']);
//
//     final shopAddress = s(shop['address']);
//     final instagramHandle = s(shop['instagramHandle']);
//     final addrHost = s(shop['addr_host']);
//
//     // اطلاعات مشتری از سفارش
//     final customerName = s(order.shippingAddress?.street);
//     final customerPhone = s(order.shippingAddress?.phone);
//
//     // حضوری/آنلاین
//     final tableNumber = s(order.shippingAddress?.tableNumber ?? order.tableNumber);
//     final deliveryAddress = s(order.shippingAddress?.state);
//
//     final isInPerson = (order.isInPersonOrder == true) || tableNumber.isNotEmpty;
//     final orderTypeText = isInPerson ? 'حضوری' : 'آنلاین';
//
//     final items = order.items ?? <Items>[];
//
//     // لوگو
//     pw.ImageProvider? logo;
//     if (logoUrl.isNotEmpty) {
//       try {
//         logo = await networkImage(logoUrl);
//       } catch (_) {
//         logo = null;
//       }
//     }
//
//     pw.Widget divider({double v = 1}) => pw.Padding(
//       padding: pw.EdgeInsets.symmetric(vertical: 2),
//       child: pw.Divider(thickness: 0.3, color: PdfColors.grey400),
//     );
//
//
//     pw.Widget chip(String txt) => pw.Container(
//       padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical:2),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.grey200,
//         borderRadius: pw.BorderRadius.circular(6),
//       ),
//       child: pw.Text(txt, style: t(9, bold: true)),
//     );
//
//     pw.Widget card({
//       required pw.Widget child,
//       PdfColor bg = PdfColors.grey100,
//       PdfColor border = PdfColors.grey300,
//     }) =>
//         pw.Container(
//           padding: const pw.EdgeInsets.all(5),
//           decoration: pw.BoxDecoration(
//             color: bg,
//             borderRadius: pw.BorderRadius.circular(10),
//             border: pw.Border.all(color: border, width: 1),
//           ),
//           child: child,
//         );
//
//     pw.Widget rowKV(
//         String key,
//         String value, {
//           bool boldVal = false,
//           PdfColor? valColor,
//         }) {
//       return pw.Padding(
//         padding: const pw.EdgeInsets.symmetric(vertical: 2),
//         child: pw.Row(
//           children: [
//             pw.Text(key, style: t(10, bold: true), textAlign: pw.TextAlign.right),
//             pw.SizedBox(width: 3),
//             pw.Text(
//               value,
//               style: t(10, bold: boldVal, color: valColor),
//               textAlign: pw.TextAlign.right,
//             ),
//           ],
//         ),
//       );
//     }
//
//     pw.Widget sectionTitle(String title) => pw.Container(
//       width: double.infinity,
//       padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.grey300,
//         borderRadius: pw.BorderRadius.circular(8),
//       ),
//       child: pw.Text(title, style: t(11, bold: true), textAlign: pw.TextAlign.right),
//     );
//
//
//     pw.Widget itemsTable() {
//       pw.Widget headerCell(String txt, {pw.TextAlign align = pw.TextAlign.center}) {
//         return pw.Padding(
//           padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4), // کمتر
//           child: pw.Text(txt, style: t(10, bold: true), textAlign: align),
//         );
//       }
//
//       pw.Widget bodyCell(String txt, {pw.TextAlign align = pw.TextAlign.center}) {
//         return pw.Padding(
//           padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4), // کمتر
//           child: pw.Text(txt, style: t(10), textAlign: align),
//         );
//       }
//
//       final rows = <pw.TableRow>[];
//
//       // ✅ ترتیب ستون‌ها را جوری می‌چینیم که خروجی دقیقاً اینطور بشه:
//       // راست: محصول  | وسط: قیمت و تعداد | چپ: مبلغ
//       // پس ترتیب در Table: مبلغ، تعداد، قیمت، محصول
//       rows.add(
//         pw.TableRow(
//           decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//           children: [
//             headerCell('مبلغ'),
//             headerCell('تعداد'),
//             headerCell('قیمت'),
//             headerCell('محصول', align: pw.TextAlign.right),
//           ],
//         ),
//       );
//
//       for (final it in items) {
//         final name = s(it.productName);
//         final qty = (it.quantity ?? 0);
//         final price = (it.price ?? 0).toDouble();
//         final lineTotal = price * qty;
//
//
//         rows.add(
//           pw.TableRow(
//             decoration: const pw.BoxDecoration(color: PdfColors.white),
//             children: [
//               // مبلغ (چپ)
//               bodyCell(moneyItems(lineTotal), align: pw.TextAlign.center),
//
//               // تعداد (وسط)
//               bodyCell(qty.toString()),
//
//               // قیمت (وسط)
//               bodyCell(moneyItems(price)),
//
//               // محصول (راست) + توضیح زیرش
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//                 children: [
//                   bodyCell(name, align: pw.TextAlign.right),
//
//                 ],
//               ),
//             ],
//           ),
//         );
//       }
//
//       if (items.isEmpty) {
//         rows.add(
//           pw.TableRow(
//             children: [
//               pw.Padding(
//                 padding: const pw.EdgeInsets.all(8),
//                 child: pw.Text('آیتمی موجود نیست', style: t(10), textAlign: pw.TextAlign.right),
//               ),
//               pw.SizedBox(),
//               pw.SizedBox(),
//               pw.SizedBox(),
//             ],
//           ),
//         );
//       }
//
//       return pw.Table(
//         border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
//         columnWidths: {
//           0: const pw.FlexColumnWidth(3), // مبلغ
//           1: const pw.FlexColumnWidth(2), // تعداد
//           2: const pw.FlexColumnWidth(2), // قیمت
//           3: const pw.FlexColumnWidth(6), // محصول
//         },
//         children: rows,
//       );
//     }
//
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.MultiPage(
//        pageFormat: pageFormat ?? PdfPageFormat.roll57,
//
//         margin: const pw.EdgeInsets.all(18),
//         textDirection: pw.TextDirection.rtl,
//
//         build: (pw.Context ctx) {
//           return [
//             // ===== Header =====
//             pw.Center(
//               child: pw.Column(
//                 children: [
//                   if (logo != null)
//                   // ✅ لوگو گرد
//                     pw.Container(
//                       width: 32,
//                       height: 32,
//                       decoration: pw.BoxDecoration(
//                         color: PdfColors.white,
//                         shape: pw.BoxShape.circle,
//                         border: pw.Border.all(color: PdfColors.grey300, width: 1.5),
//                       ),
//                       child: pw.ClipOval(
//                         child: pw.Image(
//                           logo!,
//                           fit: pw.BoxFit.cover, // اگر نخواستی کراپ بشه => contain
//                         ),
//                       ),
//                     ),
//                   if (shopName.isNotEmpty) ...[
//                     pw.SizedBox(height: 3),
//                     pw.Text(shopName, style: t(15, bold: true)),
//                   ],
//                   pw.SizedBox(height: 5),
//                   chip('فاکتور'),
//                 ],
//               ),
//             ),
//
//             divider(),
//
//             // ===== Customer + Order Type Card =====
//             card(
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//                 children: [
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.end,
//                     children: [
//
//                       chip(orderTypeText),
//                     ],
//                   ),
//
//
//                   // نام مشتری
//                   if (customerName.isNotEmpty)
//                     pw.Text( 'نام مشتری: ${customerName} ', style: t(12, bold: true), textAlign: pw.TextAlign.right),
//
//                   // تلفن مشتری
//                   if (customerPhone.isNotEmpty)
//                     pw.Padding(
//                       padding: const pw.EdgeInsets.only(top: 2),
//                       child:
//
//
//                       pw.Text( 'تماس مشتری: ${customerPhone} ', style: t(11), textAlign: pw.TextAlign.right),
//                     ),
//
//                   if (customerName.isEmpty && customerPhone.isEmpty)
//                     pw.Text('-', style: t(11, color: PdfColors.grey700), textAlign: pw.TextAlign.right),
//
//                   pw.SizedBox(height: 3),
//
//                   // حضوری/آنلاین + میز/آدرس
//                   if (isInPerson) ...[
//                     rowKV('شماره میز:', dashIfEmpty(tableNumber)),
//                   ] else ...[
//                     pw.Text('آدرس دریافت:', style: t(10, bold: true), textAlign: pw.TextAlign.right),
//                     pw.SizedBox(height: 4),
//                     // چند خطی و تمام عرض
//                     pw.Text(dashIfEmpty(deliveryAddress), style: t(10), textAlign: pw.TextAlign.right),
//                   ],
//                 ],
//               ),
//             ),
//
//             divider(),
//
//             // ===== Items =====
//             sectionTitle('سفارش محصولات '),
//             pw.SizedBox(height: 5),
//             itemsTable(),
//
//             divider(),
//
//             // ===== Payment =====
//             sectionTitle('جزئیات پرداخت'),
//             pw.SizedBox(height: 5),
//             card(
//               bg: PdfColors.white,
//               border: PdfColors.grey300,
//               child: pw.Column(
//                 children: [
//                   rowKV('کد کوپن:', dashIfEmpty(s(order.couponCode))),
//                   rowKV('جمع جزء سفارش:', moneySafe(order.orderTotal?.subTotal)),
//                   rowKV('تخفیف:', moneySafe(order.orderTotal?.discount), valColor: PdfColors.red),
//                   pw.Divider(color: PdfColors.grey400),
//                   rowKV('جمع کل:', moneySafe(order.orderTotal?.total), boldVal: true),
//                 ],
//               ),
//             ),
//
//             divider(),
//
//             // ===== Footer shop info (center) =====
//             pw.Center(
//               child: pw.Column(
//                 children: [
//                   if (shopAddress.isNotEmpty)
//                     pw.Text(shopAddress, style: t(10, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                   if (instagramHandle.isNotEmpty) ...[
//                     pw.SizedBox(height: 4),
//                     pw.Text(instagramHandle, style: t(10, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                   ],
//                   if (addrHost.isNotEmpty) ...[
//                     pw.SizedBox(height: 4),
//                     pw.Text(addrHost, style: t(10, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                   ],
//                 ],
//               ),
//             ),
//           ];
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
// }

//
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
//
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
//
// import '../models/order.dart';
// import '../utility/User_helper.dart';
// import '../utility/functions.dart'; // money(ctx, ...)
// import '../utility/snack_bar_helper.dart';
//
// enum ReceiptPaper { mm58, mm80 }
//
// class InvoicePrinter {
//   static pw.Font? _faFont;
//
//   static Future<pw.Font> _loadFaFont() async {
//     if (_faFont != null) return _faFont!;
//     final data = await rootBundle.load('assets/fonts/dm.ttf');
//     _faFont = pw.Font.ttf(data);
//     return _faFont!;
//   }
//
//   /// ✅ چاپ مستقیم رسید
//   static Future<void> printReceipt(
//       BuildContext context,
//       Order order, {
//         ReceiptPaper paper = ReceiptPaper.mm80,
//       }) async {
//     try {
//       final pdfBytes = await _buildReceiptPdf(context, order, paper: paper);
//       await Printing.layoutPdf(
//         onLayout: (_) async => pdfBytes,
//         name: 'receipt_${order.sId ?? ''}.pdf',
//       );
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('خطا در چاپ رسید: $e');
//     }
//   }
//
//   /// ✅ پیش‌نمایش رسید (با انتخاب 58/80 داخل Preview)
//   static Future<void> previewReceipt(
//       BuildContext context,
//       Order order, {
//         ReceiptPaper defaultPaper = ReceiptPaper.mm80,
//       }) async {
//     try {
//       final formats = <String, PdfPageFormat>{
//         '58mm': _rollFormatFor(defaultPaper: ReceiptPaper.mm58),
//         '80mm': _rollFormatFor(defaultPaper: ReceiptPaper.mm80),
//       };
//
//       await showDialog(
//         context: context,
//         builder: (_) => Dialog(
//           child: SizedBox(
//             width: 520,
//             height: 780,
//             child: PdfPreview(
//               pageFormats: formats,
//               initialPageFormat: defaultPaper == ReceiptPaper.mm58 ? formats['58mm']! : formats['80mm']!,
//               canChangePageFormat: true,
//               canChangeOrientation: false,
//               // نکته: build اینجا format را می‌دهد؛ ما از عرضش scale می‌گیریم
//               build: (format) async {
//                 // با توجه به عرض انتخاب‌شده در Preview، paper را حدس می‌زنیم
//                 final widthMm = format.width / PdfPageFormat.mm;
//                 final guessedPaper = (widthMm <= 65) ? ReceiptPaper.mm58 : ReceiptPaper.mm80;
//                 return _buildReceiptPdf(context, order, paper: guessedPaper, previewFormat: format);
//               },
//               pdfFileName: 'receipt_${order.sId ?? ''}.pdf',
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('خطا در پیش‌نمایش رسید: $e');
//     }
//   }
//
//   static PdfPageFormat _rollFormatFor({required ReceiptPaper defaultPaper}) {
//     final w = defaultPaper == ReceiptPaper.mm58 ? 58.0 : 80.0;
//     // اینجا ارتفاع موقت است؛ ما در build ارتفاع واقعی را می‌سازیم
//     return PdfPageFormat(w * PdfPageFormat.mm, 200 * PdfPageFormat.mm, marginAll: 4 * PdfPageFormat.mm);
//   }
//
//   /// ✅ ساخت PDF رسید یک‌صفحه‌ای (بلند) و رسپانسیو
//   static Future<Uint8List> _buildReceiptPdf(
//       BuildContext context,
//       Order order, {
//         required ReceiptPaper paper,
//         PdfPageFormat? previewFormat, // فقط برای اینکه اگر Preview format داد، از عرضش استفاده کنیم
//       }) async {
//     final faFont = await _loadFaFont();
//
//     // fallback برای لاتین/علائم مثل @ . - ...
//     final fallback1 = pw.Font.helvetica();
//     final fallback2 = pw.Font.helveticaBold();
//
//     String s(dynamic v) => (v ?? '').toString().trim();
//     String dashIfEmpty(String v) => v.isEmpty ? '-' : v;
//     String moneySafe(num? n) => money(context, (n ?? 0).toDouble());
//
//     // --- داده‌ها
//     final shop = await UserSaveHelper.getUserInfo(showError: false) ?? {};
//     final logoUrl = s(shop['icon_logo_url']);
//     final shopName = s(shop['name_bizi']);
//     final shopAddress = s(shop['address']);
//     final instagramHandle = s(shop['instagramHandle']);
//     final addrHost = s(shop['addr_host']);
//
//     final customerName = s(order.shippingAddress?.street);
//     final customerPhone = s(order.shippingAddress?.phone);
//
//     final tableNumber = s(order.shippingAddress?.tableNumber ?? order.tableNumber);
//     final deliveryAddress = s(order.shippingAddress?.state);
//
//     final isInPerson = (order.isInPersonOrder == true) || tableNumber.isNotEmpty;
//     final orderTypeText = isInPerson ? 'حضوری' : 'آنلاین';
//
//     final items = order.items ?? <Items>[];
//
//     // --- لوگو
//     pw.ImageProvider? logo;
//     if (logoUrl.isNotEmpty) {
//       try {
//         logo = await networkImage(logoUrl);
//       } catch (_) {
//         logo = null;
//       }
//     }
//
//     // --- عرض و scale (رسپانسیو)
//     final targetWidthPt = previewFormat?.width ??
//         ((paper == ReceiptPaper.mm58 ? 58.0 : 80.0) * PdfPageFormat.mm);
//
//     final baseWidthPt = 80.0 * PdfPageFormat.mm; // مبنا را 80mm می‌گیریم
//     final scale = (targetWidthPt / baseWidthPt).clamp(0.72, 1.15);
//
//     double sp(double v) => (v * scale).clamp(6.0, 22.0); // font size
//     double gp(double v) => (v * scale); // gaps/padding
//
//     pw.TextStyle t(double size, {bool bold = false, PdfColor? color}) => pw.TextStyle(
//       font: faFont,
//       fontFallback: [fallback1, fallback2],
//       fontSize: sp(size),
//       fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//       color: color ?? PdfColors.black,
//       lineSpacing: 1.2,
//     );
//
//     pw.Widget divider() => pw.Padding(
//       padding: pw.EdgeInsets.symmetric(vertical: gp(4)),
//       child: pw.Divider(thickness: 0.4, color: PdfColors.grey500),
//     );
//
//     pw.Widget chip(String txt) => pw.Container(
//       padding: pw.EdgeInsets.symmetric(horizontal: gp(6), vertical: gp(2)),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.grey200,
//         borderRadius: pw.BorderRadius.circular(gp(6)),
//       ),
//       child: pw.Text(txt, style: t(9, bold: true)),
//     );
//
//     pw.Widget kv(String key, String value, {PdfColor? valueColor, bool boldValue = false}) {
//       return pw.Padding(
//         padding: pw.EdgeInsets.symmetric(vertical: gp(1.5)),
//         child: pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Expanded(
//               flex: 6,
//               child: pw.Text(value, style: t(9, bold: boldValue, color: valueColor), textAlign: pw.TextAlign.left),
//             ),
//             pw.SizedBox(width: gp(6)),
//             pw.Expanded(
//               flex: 5,
//               child: pw.Text(key, style: t(9, bold: true), textAlign: pw.TextAlign.right),
//             ),
//           ],
//         ),
//       );
//     }
//
//     pw.Widget itemRow(Items it) {
//       final name = s(it.productName);
//       final qty = (it.quantity ?? 0);
//       final price = (it.price ?? 0).toDouble();
//       final total = price * qty;
//       final note = s(it.note);
//
//       // ستون‌بندی برای عرض کم: محصول راست، قیمت/تعداد وسط، مبلغ چپ
//       return pw.Padding(
//         padding: pw.EdgeInsets.only(bottom: gp(5)),
//         child: pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//           children: [
//             pw.Row(
//               children: [
//                 // مبلغ
//                 pw.SizedBox(
//                   width: targetWidthPt * 0.24,
//                   child: pw.Text(moneySafe(total), style: t(9), textAlign: pw.TextAlign.left),
//                 ),
//                 // تعداد
//                 pw.SizedBox(
//                   width: targetWidthPt * 0.14,
//                   child: pw.Text(qty.toString(), style: t(9), textAlign: pw.TextAlign.center),
//                 ),
//                 // قیمت
//                 pw.SizedBox(
//                   width: targetWidthPt * 0.24,
//                   child: pw.Text(moneySafe(price), style: t(9), textAlign: pw.TextAlign.center),
//                 ),
//                 // نام محصول (Flexible برای اینکه دفرمه نشه)
//                 pw.Expanded(
//                   child: pw.Text(
//                     name,
//                     style: t(9),
//                     textAlign: pw.TextAlign.right,
//                     maxLines: 2,
//                     overflow: pw.TextOverflow.clip,
//                   ),
//                 ),
//               ],
//             ),
//             if (note.isNotEmpty)
//               pw.Padding(
//                 padding: pw.EdgeInsets.only(top: gp(2)),
//                 child: pw.Text(
//                   'توضیح: $note',
//                   style: t(8, color: PdfColors.grey800),
//                   textAlign: pw.TextAlign.right,
//                   maxLines: 3,
//                   overflow: pw.TextOverflow.clip,
//                 ),
//               ),
//           ],
//         ),
//       );
//     }
//
//     // --- تخمین ارتفاع (برای یک صفحه بلند)
//     // اعداد را طوری گذاشتم که برای اکثر رسیدها خوب جواب بده؛ اگر فونت/فاصله را تغییر دادی اینجا را هم کمی تنظیم کن.
//     final hasNotesCount = items.where((e) => s(e.note).isNotEmpty).length;
//
//     final baseMm = 85.0; // هدر + مشتری + پرداخت + فوتر (تقریبی)
//     final perItemMm = 9.0; // هر آیتم یک ردیف
//     final perNoteMm = 5.0; // هر note چند خط اضافه
//     final extraMm = 10.0; // حاشیه امن
//
//     final estimatedHeightMm = (baseMm +
//         (items.length * perItemMm) +
//         (hasNotesCount * perNoteMm) +
//         extraMm) *
//         (scale); // با scale همگام
//
//     // حداقل/حداکثر منطقی برای جلوگیری از خراب شدن Viewerها
//     final safeHeightMm = estimatedHeightMm.clamp(180.0, 2000.0);
//
//     final pageFormat = PdfPageFormat(
//       targetWidthPt,
//       safeHeightMm * PdfPageFormat.mm,
//       marginTop: gp(4) * PdfPageFormat.mm / PdfPageFormat.mm,
//       marginBottom: gp(4) * PdfPageFormat.mm / PdfPageFormat.mm,
//       marginLeft: gp(4) * PdfPageFormat.mm / PdfPageFormat.mm,
//       marginRight: gp(4) * PdfPageFormat.mm / PdfPageFormat.mm,
//     );
//
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.Page(
//         pageFormat: pageFormat,
//         textDirection: pw.TextDirection.rtl,
//         build: (ctx) {
//           return pw.Container(
//             width: double.infinity,
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//               children: [
//                 // ===== Header =====
//                 pw.Center(
//                   child: pw.Column(
//                     children: [
//                       if (logo != null)
//                         pw.Container(
//                           width: gp(28),
//                           height: gp(28),
//                           decoration: pw.BoxDecoration(
//                             shape: pw.BoxShape.circle,
//                             border: pw.Border.all(color: PdfColors.grey400, width: 1),
//                           ),
//                           child: pw.ClipOval(child: pw.Image(logo!, fit: pw.BoxFit.cover)),
//                         ),
//                       if (shopName.isNotEmpty) ...[
//                         pw.SizedBox(height: gp(4)),
//                         pw.Text(shopName, style: t(12, bold: true), textAlign: pw.TextAlign.center),
//                       ],
//                       pw.SizedBox(height: gp(6)),
//                       chip('فاکتور'),
//                     ],
//                   ),
//                 ),
//
//                 divider(),
//
//                 // ===== Customer & Type =====
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('receipt_${order.sId ?? ''}', style: t(8, color: PdfColors.grey700), textAlign: pw.TextAlign.left),
//                     chip(orderTypeText),
//                   ],
//                 ),
//                 pw.SizedBox(height: gp(6)),
//
//                 if (customerName.isNotEmpty) pw.Text('نام مشتری: $customerName', style: t(10, bold: true), textAlign: pw.TextAlign.right),
//                 if (customerPhone.isNotEmpty) pw.Text('تماس مشتری: $customerPhone', style: t(9), textAlign: pw.TextAlign.right),
//                 if (customerName.isEmpty && customerPhone.isEmpty)
//                   pw.Text('-', style: t(9, color: PdfColors.grey700), textAlign: pw.TextAlign.right),
//
//                 pw.SizedBox(height: gp(6)),
//
//                 if (isInPerson)
//                   pw.Text('شماره میز: ${dashIfEmpty(tableNumber)}', style: t(9), textAlign: pw.TextAlign.right)
//                 else ...[
//                   pw.Text('آدرس دریافت:', style: t(9, bold: true), textAlign: pw.TextAlign.right),
//                   pw.SizedBox(height: gp(3)),
//                   pw.Text(dashIfEmpty(deliveryAddress), style: t(9), textAlign: pw.TextAlign.right),
//                 ],
//
//                 divider(),
//
//                 // ===== Items =====
//                 pw.Text('سفارش محصولات', style: t(10, bold: true), textAlign: pw.TextAlign.right),
//                 pw.SizedBox(height: gp(6)),
//
//                 // سرستون کوچک
//                 pw.Row(
//                   children: [
//                     pw.SizedBox(width: targetWidthPt * 0.24, child: pw.Text('مبلغ', style: t(8, bold: true), textAlign: pw.TextAlign.left)),
//                     pw.SizedBox(width: targetWidthPt * 0.14, child: pw.Text('تعداد', style: t(8, bold: true), textAlign: pw.TextAlign.center)),
//                     pw.SizedBox(width: targetWidthPt * 0.24, child: pw.Text('قیمت', style: t(8, bold: true), textAlign: pw.TextAlign.center)),
//                     pw.Expanded(child: pw.Text('محصول', style: t(8, bold: true), textAlign: pw.TextAlign.right)),
//                   ],
//                 ),
//                 pw.Divider(thickness: 0.4, color: PdfColors.grey500),
//
//                 if (items.isEmpty)
//                   pw.Padding(
//                     padding: pw.EdgeInsets.symmetric(vertical: gp(8)),
//                     child: pw.Text('آیتمی موجود نیست', style: t(9), textAlign: pw.TextAlign.center),
//                   )
//                 else
//                   ...items.map(itemRow),
//
//                 divider(),
//
//                 // ===== Payment =====
//                 pw.Text('جزئیات پرداخت', style: t(10, bold: true), textAlign: pw.TextAlign.right),
//                 pw.SizedBox(height: gp(6)),
//                 kv('کد کوپن', dashIfEmpty(s(order.couponCode))),
//                 kv('جمع جزء سفارش', moneySafe(order.orderTotal?.subTotal)),
//                 kv('تخفیف', moneySafe(order.orderTotal?.discount), valueColor: PdfColors.red),
//                 pw.Divider(thickness: 0.4, color: PdfColors.grey500),
//                 kv('جمع کل', moneySafe(order.orderTotal?.total), boldValue: true),
//
//                 divider(),
//
//                 // ===== Footer =====
//                 if (shopAddress.isNotEmpty)
//                   pw.Text(shopAddress, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                 if (instagramHandle.isNotEmpty)
//                   pw.Padding(
//                     padding: pw.EdgeInsets.only(top: gp(2)),
//                     child: pw.Text(instagramHandle, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                   ),
//                 if (addrHost.isNotEmpty)
//                   pw.Padding(
//                     padding: pw.EdgeInsets.only(top: gp(2)),
//                     child: pw.Text(addrHost, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//
//     return pdf.save();
//   }
// }

// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import '../models/order.dart';
// import '../utility/User_helper.dart';
// import '../utility/functions.dart';
// import '../utility/snack_bar_helper.dart';
//
// enum ReceiptPaper { mm58, mm80 }
//
// class InvoicePrinter {
//   static pw.Font? _font;
//
//   static Future<pw.Font> _loadFont() async {
//     if (_font != null) return _font!;
//     final data = await rootBundle.load('assets/fonts/dm.ttf');
//     _font = pw.Font.ttf(data);
//     return _font!;
//   }
//
//   static Future<void> printReceipt(
//       BuildContext context,
//       Order order, {
//         ReceiptPaper paper = ReceiptPaper.mm80,
//       }) async {
//     try {
//       final pdfBytes = await _buildPdf(context, order, paper: paper);
//       await Printing.layoutPdf(
//         onLayout: (_) async => pdfBytes,
//         name: 'receipt_${order.sId ?? ''}.pdf',
//       );
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('خطا در چاپ رسید: $e');
//     }
//   }
//
//   static Future<void> previewReceipt(
//       BuildContext context,
//       Order order, {
//         ReceiptPaper defaultPaper = ReceiptPaper.mm80,
//       }) async {
//     try {
//       final formats = <String, PdfPageFormat>{
//         '58mm': _rollFormatFor(ReceiptPaper.mm58),
//         '80mm': _rollFormatFor(ReceiptPaper.mm80),
//       };
//
//       await showDialog(
//         context: context,
//         builder: (_) => Dialog(
//           child: SizedBox(
//             width: 520,
//             height: 780,
//             child: PdfPreview(
//               pageFormats: formats,
//               initialPageFormat:
//               defaultPaper == ReceiptPaper.mm58 ? formats['58mm']! : formats['80mm']!,
//               canChangePageFormat: true,
//               canChangeOrientation: false,
//               build: (format) async {
//                 final widthMm = format.width / PdfPageFormat.mm;
//                 final guessedPaper = (widthMm <= 65) ? ReceiptPaper.mm58 : ReceiptPaper.mm80;
//                 return _buildPdf(context, order,
//                     paper: guessedPaper, previewFormat: format);
//               },
//               pdfFileName: 'receipt_${order.sId ?? ''}.pdf',
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       SnackBarHelper.showErrorSnackBar('خطا در پیش‌نمایش رسید: $e');
//     }
//   }
//
//   static PdfPageFormat _rollFormatFor(ReceiptPaper paper) {
//     final w = paper == ReceiptPaper.mm58 ? 58.0 : 80.0;
//     return PdfPageFormat(w * PdfPageFormat.mm, 200 * PdfPageFormat.mm,
//         marginAll: 4 * PdfPageFormat.mm);
//   }
//
//   static Future<Uint8List> _buildPdf(
//       BuildContext context,
//       Order order, {
//         required ReceiptPaper paper,
//         PdfPageFormat? previewFormat,
//       }) async {
//     final font = await _loadFont();
//     final fallback1 = pw.Font.helvetica();
//     final fallback2 = pw.Font.helveticaBold();
//
//     final targetWidthPt = previewFormat?.width ??
//         ((paper == ReceiptPaper.mm58 ? 58.0 : 80.0) * PdfPageFormat.mm);
//     final baseWidthPt = 80.0 * PdfPageFormat.mm;
//     final scale = (targetWidthPt / baseWidthPt).clamp(0.7, 1.2);
//
//     double sp(double v) => (v * scale).clamp(6.0, 20.0);
//     double gp(double v) => (v * scale).clamp(1.0, 12.0);
//
//     pw.TextStyle t(double size,
//         {bool bold = false, PdfColor? color}) =>
//         pw.TextStyle(
//           font: font,
//           fontFallback: [fallback1, fallback2],
//           fontSize: sp(size),
//           fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
//           color: color ?? PdfColors.black,
//           lineSpacing: 1.1,
//         );
//
//     String s(dynamic v) => (v ?? '').toString().trim();
//     String dashIfEmpty(String v) => v.isEmpty ? '-' : v;
//
//     String moneySafe(num? n) => money(context, (n ?? 0).toDouble());
//
//     String moneyItems(num? n) {
//       final txt = money(context, (n ?? 0).toDouble());
//       return txt.replaceAll('ریال', '').replaceAll('  ', ' ').trim();
//     }
//
//     final shop = await UserSaveHelper.getUserInfo(showError: false) ?? {};
//     final logoUrl = s(shop['icon_logo_url']);
//     final shopName = s(shop['name_bizi']);
//     final shopAddress = s(shop['address']);
//     final instagramHandle = s(shop['instagramHandle']);
//     final addrHost = s(shop['addr_host']);
//
//     final customerName = s(order.shippingAddress?.street);
//     final customerPhone = s(order.shippingAddress?.phone);
//     final tableNumber = s(order.shippingAddress?.tableNumber ?? order.tableNumber);
//     final deliveryAddress = s(order.shippingAddress?.state);
//     final isInPerson = (order.isInPersonOrder == true) || tableNumber.isNotEmpty;
//     final orderTypeText = isInPerson ? 'حضوری' : 'آنلاین';
//     final items = order.items ?? <Items>[];
//
//     pw.ImageProvider? logo;
//     if (logoUrl.isNotEmpty) {
//       try {
//         logo = await networkImage(logoUrl);
//       } catch (_) {}
//     }
//
//
//     pw.Widget chip(String txt) => pw.Container(
//       padding: pw.EdgeInsets.symmetric(horizontal: gp(8), vertical: gp(2)),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.grey200,
//         borderRadius: pw.BorderRadius.circular(gp(6)),
//       ),
//       child: pw.Text(txt, style: t(9, bold: true)),
//     );
//
//     pw.Widget card({
//       required pw.Widget child,
//       PdfColor bg = PdfColors.grey100,
//       PdfColor border = PdfColors.grey300,
//     }) =>
//         pw.Container(
//           padding: pw.EdgeInsets.all(gp(6)),
//           decoration: pw.BoxDecoration(
//             color: bg,
//             borderRadius: pw.BorderRadius.circular(gp(10)),
//             border: pw.Border.all(color: border, width: 1),
//           ),
//           child: child,
//         );
//
//     pw.Widget rowKV(String key, String value,
//         {bool boldVal = false, PdfColor? valColor}) {
//       return pw.Padding(
//         padding: pw.EdgeInsets.symmetric(vertical: gp(2)),
//         child: pw.Row(
//           children: [
//             pw.Text(key, style: t(10, bold: true)),
//             pw.SizedBox(width: gp(3)),
//             pw.Text(value, style: t(10, bold: boldVal, color: valColor)),
//           ],
//         ),
//       );
//     }
//
//     pw.Widget sectionTitle(String title) => pw.Container(
//       width: double.infinity,
//       padding: pw.EdgeInsets.symmetric(horizontal: gp(10), vertical: gp(4)),
//       decoration: pw.BoxDecoration(
//         color: PdfColors.grey300,
//         borderRadius: pw.BorderRadius.circular(gp(8)),
//       ),
//       child: pw.Text(title, style: t(11, bold: true)),
//     );
//
//     // جدول محصولات - تنظیم نهایی طبق درخواستت
//     pw.Widget itemsTable() {
//       final is58mm = scale < 0.9;
//
//       final headerFontSize = is58mm ? 7.2 : 8.0;
//       final bodyFontSize = is58mm ? 6.8 : 7.5;
//
//       pw.Widget headerCell(String txt, {pw.TextAlign align = pw.TextAlign.center}) =>
//           pw.Padding(
//             padding: pw.EdgeInsets.symmetric(vertical: gp(1.2), horizontal: gp(1.5)),
//             child: pw.Text(txt, style: t(headerFontSize, bold: true), textAlign: align),
//           );
//
//       pw.Widget bodyCell(String txt,
//           {pw.TextAlign align = pw.TextAlign.center, int maxLines = 6}) =>
//           pw.Padding(
//             padding: pw.EdgeInsets.symmetric(vertical: gp(1.2), horizontal: gp(1.5)),
//             child: pw.Text(
//               txt,
//               style: t(bodyFontSize),
//               textAlign: align,
//               maxLines: maxLines,
//               overflow: pw.TextOverflow.clip,
//             ),
//           );
//
//       final rows = <pw.TableRow>[];
//
//       rows.add(pw.TableRow(
//         decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//         children: [
//           headerCell('مبلغ'),
//           headerCell('تعداد'),
//           headerCell('قیمت'),
//           headerCell('محصول', align: pw.TextAlign.right),
//         ],
//       ));
//
//       for (final it in items) {
//         final name = s(it.productName);
//         final qty = (it.quantity ?? 0).toString();
//         final price = moneyItems(it.price);
//         final total = moneyItems((it.price ?? 0) * (it.quantity ?? 0));
//
//         rows.add(pw.TableRow(
//           children: [
//             bodyCell(total, align: pw.TextAlign.left),
//             bodyCell(qty),
//             bodyCell(price),
//             bodyCell(name, align: pw.TextAlign.right),
//           ],
//         ));
//       }
//
//       if (items.isEmpty) {
//         rows.add(pw.TableRow(children: [
//           pw.Padding(
//             padding: pw.EdgeInsets.all(gp(8)),
//             child: pw.Text('آیتمی موجود نیست', style: t(9), textAlign: pw.TextAlign.center),
//           ),
//           pw.SizedBox(),
//           pw.SizedBox(),
//           pw.SizedBox(),
//         ]));
//       }
//
//       // تنظیم نهایی عرض ستون‌ها طبق درخواستت
//       final equalFlex = is58mm ? 3.3 : 3.0;     // مبلغ و قیمت جادارتر روی 58mm
//       final qtyFlex = is58mm ? 1.6 : 1.8;       // تعداد کمی جادارتر
//       final productFlex = is58mm ? 8.0 : 6.5;   // محصول هنوز بیشترین فضا، اما متعادل
//
//       return pw.Table(
//         border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
//         columnWidths: {
//           0: pw.FlexColumnWidth(equalFlex),      // مبلغ
//           1: pw.FlexColumnWidth(qtyFlex),        // تعداد
//           2: pw.FlexColumnWidth(equalFlex),      // قیمت (برابر مبلغ)
//           3: pw.FlexColumnWidth(productFlex),    // محصول
//         },
//         children: rows,
//       );
//     }
//
//     final itemCount = items.length;
//     final baseMm = 120.0;
//     final perItemMm = 9.0;
//     final estimatedHeightMm = (baseMm + itemCount * perItemMm + 40) * scale;
//     final safeHeightMm = estimatedHeightMm.clamp(220.0, 2500.0);
//
//     final pageFormat = PdfPageFormat(
//       targetWidthPt,
//       safeHeightMm * PdfPageFormat.mm,
//       marginAll: gp(5),
//     );
//
//     final pdf = pw.Document();
//
//     pdf.addPage(pw.Page(
//       pageFormat: pageFormat,
//       textDirection: pw.TextDirection.rtl,
//       build: (ctx) {
//         return pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//           children: [
//             pw.Center(
//               child: pw.Column(
//                 children: [
//                   if (logo != null)
//                     pw.Container(
//                       width: 42,
//                       height: 42,
//                       decoration: pw.BoxDecoration(
//                         shape: pw.BoxShape.circle,
//                         border: pw.Border.all(color: PdfColors.grey300, width: 1.5),
//                       ),
//                       child: pw.ClipOval(child: pw.Image(logo!, fit: pw.BoxFit.cover)),
//                     ),
//                   if (shopName.isNotEmpty) ...[
//                     pw.SizedBox(height: gp(4)),
//                     pw.Text(shopName, style: t(14, bold: true)),
//                   ],
//                   pw.SizedBox(height: gp(6)),
//                   chip('فاکتور'),
//                   pw.SizedBox(height: gp(5)),
//                 ],
//               ),
//             ),
//
//             card(
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.stretch,
//                 children: [
//                   pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [chip(orderTypeText)]),
//                   if (customerName.isNotEmpty) pw.Text('نام مشتری: $customerName', style: t(11, bold: true)),
//                   if (customerPhone.isNotEmpty)
//                     pw.Padding(padding: pw.EdgeInsets.only(top: gp(2)), child: pw.Text('تماس مشتری: $customerPhone', style: t(10))),
//                   if (customerName.isEmpty && customerPhone.isEmpty)
//                     pw.Text('-', style: t(10, color: PdfColors.grey700)),
//                   pw.SizedBox(height: gp(4)),
//                   if (isInPerson)
//                     rowKV('شماره میز:', dashIfEmpty(tableNumber))
//                   else ...[
//                     pw.Text('آدرس دریافت:', style: t(10, bold: true)),
//                     pw.SizedBox(height: gp(4)),
//                     pw.Text(dashIfEmpty(deliveryAddress), style: t(10)),
//                   ],
//                 ],
//               ),
//             ),
//
//             pw.SizedBox(height: gp(5)),
//             sectionTitle('سفارش محصولات'),
//             pw.SizedBox(height: gp(5)),
//             itemsTable(),
//
//             pw.SizedBox(height: gp(5)),
//             sectionTitle('جزئیات پرداخت'),
//             pw.SizedBox(height: gp(5)),
//             card(
//               bg: PdfColors.white,
//               child: pw.Column(
//                 children: [
//                   rowKV('کد کوپن:', dashIfEmpty(s(order.couponCode))),
//                   rowKV('جمع جزء سفارش:', moneySafe(order.orderTotal?.subTotal)),
//                   rowKV('تخفیف:', moneySafe(order.orderTotal?.discount), valColor: PdfColors.red),
//                   pw.Divider(color: PdfColors.grey400),
//                   rowKV('جمع کل:', moneySafe(order.orderTotal?.total), boldVal: true),
//                 ],
//               ),
//             ),
//             // divider(),
//             pw.Center(
//               child: pw.Column(
//                 children: [
//                   if (shopAddress.isNotEmpty)
//                     pw.Text(shopAddress, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                   if (instagramHandle.isNotEmpty) ...[
//                     pw.SizedBox(height: gp(3)),
//                     pw.Text(instagramHandle, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                   ],
//                   if (addrHost.isNotEmpty) ...[
//                     pw.SizedBox(height: gp(3)),
//                     pw.Text(addrHost, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     ));
//
//     return pdf.save();
//   }
//
//
// }



import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';
import '../utility/User_helper.dart';
import '../utility/functions.dart';
import '../utility/snack_bar_helper.dart';

enum ReceiptPaper { mm58, mm80 }

class InvoicePrinter {
  static pw.Font? _font;

  static Future<pw.Font> _loadFont() async {
    if (_font != null) return _font!;
    final data = await rootBundle.load('assets/fonts/dm.ttf');
    _font = pw.Font.ttf(data);
    return _font!;
  }

  static Future<void> printReceipt(
      BuildContext context,
      Order order, {
        ReceiptPaper paper = ReceiptPaper.mm80,
      }) async {
    try {
      final pdfBytes = await _buildPdf(context, order, paper: paper);
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'receipt_${order.sId ?? ''}.pdf',
      );
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا در چاپ رسید: $e');
    }
  }

  static Future<void> previewReceipt(
      BuildContext context,
      Order order, {
        ReceiptPaper defaultPaper = ReceiptPaper.mm80,
      }) async {
    try {
      final formats = <String, PdfPageFormat>{
        '58mm': _rollFormatFor(ReceiptPaper.mm58),
        '80mm': _rollFormatFor(ReceiptPaper.mm80),
      };

      await showDialog(
        context: context,
        builder: (_) => Dialog(
          child: SizedBox(
            width: 520,
            height: 780,
            child: PdfPreview(
              pageFormats: formats,
              initialPageFormat:
              defaultPaper == ReceiptPaper.mm58 ? formats['58mm']! : formats['80mm']!,
              canChangePageFormat: true,
              canChangeOrientation: false,
              build: (format) async {
                final widthMm = format.width / PdfPageFormat.mm;
                final guessedPaper = (widthMm <= 65) ? ReceiptPaper.mm58 : ReceiptPaper.mm80;
                return _buildPdf(context, order,
                    paper: guessedPaper, previewFormat: format);
              },
              pdfFileName: 'receipt_${order.sId ?? ''}.pdf',
            ),
          ),
        ),
      );
    } catch (e) {
      SnackBarHelper.showErrorSnackBar('خطا در پیش‌نمایش رسید: $e');
    }
  }

  static PdfPageFormat _rollFormatFor(ReceiptPaper paper) {
    final w = paper == ReceiptPaper.mm58 ? 58.0 : 80.0;
    return PdfPageFormat(w * PdfPageFormat.mm, 200 * PdfPageFormat.mm,
        marginAll: 4 * PdfPageFormat.mm);
  }

  static Future<Uint8List> _buildPdf(
      BuildContext context,
      Order order, {
        required ReceiptPaper paper,
        PdfPageFormat? previewFormat,
      }) async {
    final font = await _loadFont();
    final fallback1 = pw.Font.helvetica();
    final fallback2 = pw.Font.helveticaBold();

    final targetWidthPt = previewFormat?.width ??
        ((paper == ReceiptPaper.mm58 ? 58.0 : 80.0) * PdfPageFormat.mm);
    final baseWidthPt = 80.0 * PdfPageFormat.mm;
    final scale = (targetWidthPt / baseWidthPt).clamp(0.7, 1.2);

    // محدودتر کردن فونت و فاصله‌ها برای فشرده‌تر شدن
    double sp(double v) => (v * scale).clamp(6.0, 18.0);
    double gp(double v) => (v * scale).clamp(1.0, 10.0);

    pw.TextStyle t(double size,
        {bool bold = false, PdfColor? color}) =>
        pw.TextStyle(
          font: font,
          fontFallback: [fallback1, fallback2],
          fontSize: sp(size),
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
          lineSpacing: 1.1,
        );

    String s(dynamic v) => (v ?? '').toString().trim();
    String dashIfEmpty(String v) => v.isEmpty ? '-' : v;

    String moneySafe(num? n) => money(context, (n ?? 0).toDouble());

    String moneyItems(num? n) {
      final txt = money(context, (n ?? 0).toDouble());
      return txt.replaceAll('ریال', '').replaceAll('  ', ' ').trim();
    }

    final shop = await UserSaveHelper.getUserInfo(showError: false) ?? {};
    final logoUrl = s(shop['icon_logo_url']);
    final shopName = s(shop['name_bizi']);
    final shopAddress = s(shop['address']);
    final instagramHandle = s(shop['instagramHandle']);
    final addrHost = s(shop['addr_host']);

    final customerName = s(order.shippingAddress?.street);
    final customerPhone = s(order.shippingAddress?.phone);
    final tableNumber = s(order.shippingAddress?.tableNumber ?? order.tableNumber);
    final deliveryAddress = s(order.shippingAddress?.state);
    final isInPerson = (order.isInPersonOrder == true) || tableNumber.isNotEmpty;
    final orderTypeText = isInPerson ? 'حضوری' : 'آنلاین';
    final items = order.items ?? <Items>[];

    pw.ImageProvider? logo;
    if (logoUrl.isNotEmpty) {
      try {
        logo = await networkImage(logoUrl);
      } catch (_) {}
    }

    // chip کوچکتر
    pw.Widget chip(String txt) => pw.Container(
      padding: pw.EdgeInsets.symmetric(horizontal: gp(6), vertical: gp(1.5)),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(gp(6)),
      ),
      child: pw.Text(txt, style: t(9, bold: true)),
    );

    // card کوچکتر
    pw.Widget card({
      required pw.Widget child,
      PdfColor bg = PdfColors.grey100,
      PdfColor border = PdfColors.grey300,
    }) =>
        pw.Container(
          padding: pw.EdgeInsets.all(gp(4)),
          decoration: pw.BoxDecoration(
            color: bg,
            borderRadius: pw.BorderRadius.circular(gp(10)),
            border: pw.Border.all(color: border, width: 1),
          ),
          child: child,
        );

    // فاصله عمودی کمتر در rowKV
    pw.Widget rowKV(String key, String value,
        {bool boldVal = false, PdfColor? valColor}) {
      return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: gp(1)),
        child: pw.Row(
          children: [
            pw.Text(key, style: t(10, bold: true)),
            pw.SizedBox(width: gp(3)),
            pw.Text(value, style: t(10, bold: boldVal, color: valColor)),
          ],
        ),
      );
    }

    pw.Widget sectionTitle(String title) => pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.symmetric(horizontal: gp(10), vertical: gp(4)),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        borderRadius: pw.BorderRadius.circular(gp(8)),
      ),
      child: pw.Text(title, style: t(11, bold: true)),
    );

    // جدول محصولات (همان تنظیمات قبلی شما)
    pw.Widget itemsTable() {
      final is58mm = scale < 0.9;

      final headerFontSize = is58mm ? 7.2 : 8.0;
      final bodyFontSize = is58mm ? 6.8 : 7.5;

      pw.Widget headerCell(String txt, {pw.TextAlign align = pw.TextAlign.center}) =>
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: gp(1.2), horizontal: gp(1.5)),
            child: pw.Text(txt, style: t(headerFontSize, bold: true), textAlign: align),
          );

      pw.Widget bodyCell(String txt,
          {pw.TextAlign align = pw.TextAlign.center, int maxLines = 6}) =>
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: gp(1.2), horizontal: gp(1.5)),
            child: pw.Text(
              txt,
              style: t(bodyFontSize),
              textAlign: align,
              maxLines: maxLines,
              overflow: pw.TextOverflow.clip,
            ),
          );

      final rows = <pw.TableRow>[];

      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          headerCell('مبلغ'),
          headerCell('تعداد'),
          headerCell('قیمت'),
          headerCell('محصول', align: pw.TextAlign.right),
        ],
      ));

      for (final it in items) {
        final name = s(it.productName);
        final qty = (it.quantity ?? 0).toString();
        final price = moneyItems(it.price);
        final total = moneyItems((it.price ?? 0) * (it.quantity ?? 0));

        rows.add(pw.TableRow(
          children: [
            bodyCell(total, align: pw.TextAlign.left),
            bodyCell(qty),
            bodyCell(price),
            bodyCell(name, align: pw.TextAlign.right),
          ],
        ));
      }

      if (items.isEmpty) {
        rows.add(pw.TableRow(children: [
          pw.Padding(
            padding: pw.EdgeInsets.all(gp(8)),
            child: pw.Text('آیتمی موجود نیست', style: t(9), textAlign: pw.TextAlign.center),
          ),
          pw.SizedBox(),
          pw.SizedBox(),
          pw.SizedBox(),
        ]));
      }

      final equalFlex = is58mm ? 3.3 : 3.0;
      final qtyFlex = is58mm ? 1.6 : 1.8;
      final productFlex = is58mm ? 8.0 : 6.5;

      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
        columnWidths: {
          0: pw.FlexColumnWidth(equalFlex),
          1: pw.FlexColumnWidth(qtyFlex),
          2: pw.FlexColumnWidth(equalFlex),
          3: pw.FlexColumnWidth(productFlex),
        },
        children: rows,
      );
    }

    final itemCount = items.length;

    // محاسبه ارتفاع صفحه بسیار فشرده‌تر و دقیق‌تر
    final baseMm = 80.0;      // کاهش از 120
    final perItemMm = 7.5;    // کاهش از 9
    final extraMm = 30.0;     // برای فوتر و اطلاعات اضافی

    double estimatedHeightMm = baseMm + (itemCount * perItemMm) + extraMm;

    // حداقل ارتفاع مناسب
    if (estimatedHeightMm < 160) estimatedHeightMm = 160;

    // اعمال scale
    estimatedHeightMm *= scale;

    final safeHeightMm = estimatedHeightMm.clamp(160.0, 2000.0);

    final pageFormat = PdfPageFormat(
      targetWidthPt,
      safeHeightMm * PdfPageFormat.mm,
      marginAll: gp(3), // کاهش margin از gp(5) به gp(3)
    );

    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: pageFormat,
      textDirection: pw.TextDirection.rtl,
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  if (logo != null)
                    pw.Container(
                      width: 42,
                      height: 42,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: PdfColors.grey300, width: 1.5),
                      ),
                      child: pw.ClipOval(child: pw.Image(logo!, fit: pw.BoxFit.cover)),
                    ),
                  if (shopName.isNotEmpty) ...[
                    pw.SizedBox(height: gp(3)), // کاهش از gp(4)
                    pw.Text(shopName, style: t(14, bold: true)),
                  ],
                  pw.SizedBox(height: gp(4)), // کاهش از gp(6)
                  chip('فاکتور'),
                  pw.SizedBox(height: gp(3)), // کاهش از gp(5)
                ],
              ),
            ),

            card(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [chip(orderTypeText)]),
                  if (customerName.isNotEmpty) pw.Text('نام مشتری: $customerName', style: t(11, bold: true)),
                  if (customerPhone.isNotEmpty)
                    pw.Padding(padding: pw.EdgeInsets.only(top: gp(2)), child: pw.Text('تماس مشتری: $customerPhone', style: t(10))),
                  if (customerName.isEmpty && customerPhone.isEmpty)
                    pw.Text('-', style: t(10, color: PdfColors.grey700)),
                  pw.SizedBox(height: gp(4)),
                  if (isInPerson)
                    rowKV('شماره میز:', dashIfEmpty(tableNumber))
                  else ...[
                    pw.Text('آدرس دریافت:', style: t(10, bold: true)),
                    pw.SizedBox(height: gp(4)),
                    pw.Text(dashIfEmpty(deliveryAddress), style: t(10)),
                  ],
                ],
              ),
            ),

            pw.SizedBox(height: gp(3)), // کاهش از gp(5)
            sectionTitle('سفارش محصولات'),
            pw.SizedBox(height: gp(3)), // کاهش از gp(5)
            itemsTable(),

            pw.SizedBox(height: gp(3)), // کاهش از gp(5)
            sectionTitle('جزئیات پرداخت'),
            pw.SizedBox(height: gp(3)), // کاهش از gp(5)
            card(
              bg: PdfColors.white,
              child: pw.Column(
                children: [
                  rowKV('کد کوپن:', dashIfEmpty(s(order.couponCode))),
                  rowKV('جمع جزء سفارش:', moneySafe(order.orderTotal?.subTotal)),
                  rowKV('تخفیف:', moneySafe(order.orderTotal?.discount), valColor: PdfColors.red),
                  pw.Divider(color: PdfColors.grey400),
                  rowKV('جمع کل:', moneySafe(order.orderTotal?.total), boldVal: true),
                ],
              ),
            ),

            pw.Center(
              child: pw.Column(
                children: [
                  if (shopAddress.isNotEmpty)
                    pw.Text(shopAddress, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
                  if (instagramHandle.isNotEmpty) ...[
                    pw.SizedBox(height: gp(3)),
                    pw.Text(instagramHandle, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
                  ],
                  if (addrHost.isNotEmpty) ...[
                    pw.SizedBox(height: gp(3)),
                    pw.Text(addrHost, style: t(8, color: PdfColors.grey800), textAlign: pw.TextAlign.center),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    ));

    return pdf.save();
  }
}