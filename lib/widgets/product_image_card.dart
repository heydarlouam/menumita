import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductImageCard extends StatelessWidget {
  final String labelText;
  final String? imageUrlForUpdateImage;
  final File? imageFile;
  final VoidCallback onTap;
  final VoidCallback? onRemoveImage;

  const ProductImageCard({
    Key? key,
    required this.labelText,
    this.imageFile,
    required this.onTap,
    this.imageUrlForUpdateImage,
    this.onRemoveImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Card(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 160,
              width: MediaQuery.of(context).size.width * 0.12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(
                              imageFile?.path ?? '',
                              width: double.infinity,
                              height: 80,
                              fit: BoxFit.contain,
                            )
                          : Image.file(
                              imageFile!,
                              width: double.infinity,
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                    )
                  else if (imageUrlForUpdateImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrlForUpdateImage ?? '',
                        width: double.infinity,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    Icon(Icons.camera_alt, size: 50, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    labelText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (imageFile != null && onRemoveImage != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.red,
              ),
              onPressed: onRemoveImage,
            ),
          ),
      ],
    );
  }
}


// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// class ProductImageCard extends StatelessWidget {
//   final String labelText;
//   final String? imageUrlForUpdateImage;
//   final File? imageFile;
//   final VoidCallback onTap;
//   final VoidCallback? onRemoveImage;
//
//   const ProductImageCard({
//     Key? key,
//     required this.labelText,
//     this.imageFile,
//     this.imageUrlForUpdateImage,
//     required this.onTap,
//     this.onRemoveImage,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     Widget buildImage() {
//       if (imageFile != null) {
//         // ✅ دقیقاً مثل CategoryImageCard: روی وب با Image.network از path (blob url) نمایش بده
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: kIsWeb
//               ? Image.network(
//             imageFile!.path,
//             width: double.infinity,
//             height: 110,
//             fit: BoxFit.contain,
//           )
//               : Image.file(
//             imageFile!,
//             width: double.infinity,
//             height: 110,
//             fit: BoxFit.contain,
//           ),
//         );
//       }
//
//       if (imageUrlForUpdateImage != null && imageUrlForUpdateImage!.trim().isNotEmpty) {
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             imageUrlForUpdateImage!,
//             width: double.infinity,
//             height: 110,
//             fit: BoxFit.contain,
//           ),
//         );
//       }
//
//       return const Icon(Icons.add_a_photo, size: 34);
//     }
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 170,
//         width: MediaQuery.of(context).size.width * 0.12,
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           color: Colors.grey[200],
//           border: Border.all(color: Colors.grey.shade400),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Expanded(child: Center(child: buildImage())),
//             const SizedBox(height: 8),
//             Text(
//               labelText,
//               style: const TextStyle(fontSize: 12),
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             if (onRemoveImage != null && imageFile != null)
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   icon: const Icon(Icons.delete, size: 18),
//                   onPressed: onRemoveImage,
//                   tooltip: 'حذف',
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
