
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../../models/poster.dart';
import '../../../utility/constants.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/category_image_card.dart';
import '../../../widgets/custom_text_field.dart';
import '../provider/poster_provider.dart';
import '../../../widgets/submission_spinner.dart';

class PosterSubmitForm extends StatelessWidget {
  final Poster? poster;
  const PosterSubmitForm({super.key, this.poster});

  @override
  Widget build(BuildContext context) {
    // مثل Category: ست‌کردن دیتا داخل Post-Frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.posterProvider.setDataForUpdatePoster(poster);
    });

    return SingleChildScrollView(
      child: Form(
        key: context.posterProvider.addPosterFormKey,
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(defaultPadding),

              // ✅ دقیقا مثل Category با Consumer
              Consumer<PosterProvider>(
                builder: (context, p, _) {
                  return CategoryImageCard(
                    labelText: "تصویر",
                    imageFile: p.selectedImage,               // ✅ همان selectedImage
                    imageUrlForUpdateImage: poster?.imageUrl, // تصویر قبلی سرور
                    onTap: () => p.pickImage(),               // انتخاب عکس جدید
                  );
                },
              ),

              const Gap(defaultPadding),

              CustomTextField(
                controller: context.posterProvider.posterNameCtrl,
                labelText: 'عنوان پوستر',
                validator: (v) => (v == null || v.isEmpty) ? 'لطفاً عنوان پوستر را وارد کنید' : null,
                onSave: (_) {},
              ),

              const Gap(defaultPadding * 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: secondaryColor,
                    ),
                    onPressed: () {
                      context.posterProvider.clearFields();
                      Navigator.of(context).pop();
                    },
                    child: const Text('انصراف'),
                  ),
                  const Gap(defaultPadding),
                  Consumer<PosterProvider>(
                    builder: (context, p, _) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                        ),
                        onPressed: () async {
                          if (p.isSubmitting) return;
                          final ok = await p.submitPoster();
                          if (!context.mounted) return;
                          if (ok) Navigator.of(context).pop();
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                          child: p.isSubmitting
                              ? const SubmissionSpinner(
                                  key: ValueKey('poster_loading'),
                                )
                              : const Text(
                                  'ثبت',
                                  key: ValueKey('poster_submit_text'),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAddPosterForm(BuildContext context, Poster? poster) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(
          child: Text(
            poster == null ? 'افزودن پوستر' : 'ویرایش پوستر',
            style: const TextStyle(color: primaryColor),
          ),
        ),
        content: PosterSubmitForm(poster: poster),
      );
    },
  ).then((_) {
    context.posterProvider.clearFields();
  });
}

// برای سازگاری با کدهای قدیمی
void showPosterForm(BuildContext context, Poster? poster) => showAddPosterForm(context, poster);
