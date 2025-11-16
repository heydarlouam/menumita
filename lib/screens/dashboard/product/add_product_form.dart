
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/brand.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../models/sub_category.dart';
import '../../../models/variant_type.dart';
import '../../../utility/constants.dart';
import '../../../core/data/data_provider.dart';
import '../../../utility/extensions.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/multi_select_drop_down.dart';
import '../../../widgets/product_image_card.dart';
import '../provider/dash_board_provider.dart';

class ProductSubmitForm extends StatelessWidget {
  final Product? product;

  const ProductSubmitForm({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    context.dashBoardProvider.setDataForUpdateProduct(product);

    return SingleChildScrollView(
      child: Form(
        key: context.dashBoardProvider.addProductFormKey,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildImageCard(context, 1, 'تصویر اصلی'),
                    _buildImageCard(context, 2, 'تصویر دوم'),
                    _buildImageCard(context, 3, 'تصویر سوم'),
                    _buildImageCard(context, 4, 'تصویر چهارم'),
                    _buildImageCard(context, 5, 'تصویر پنجم'),
                  ],
                ),
              ),
              SizedBox(height: defaultPadding),
              CustomTextField(
                controller: context.dashBoardProvider.productNameCtrl,
                labelText: 'نام محصول',

                onSave: (val) {},
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً نام را وارد کنید';
                  }
                  return null;
                },
              ),
              SizedBox(height: defaultPadding),
              CustomTextField(
                controller: context.dashBoardProvider.productDescCtrl,
                labelText: 'توضیحات محصول',
                lineNumber: 3,
                onSave: (val) {},
              ),
              SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(child: _buildCategoryDropdown(context)),
                  Expanded(child: _buildSubCategoryDropdown(context)),
                  Expanded(child: _buildBrandDropdown(context)),
                ],
              ),
              SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: context.dashBoardProvider.productPriceCtrl,
                      labelText: 'قیمت',
                      inputType: TextInputType.number,
                      onSave: (val) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً قیمت را وارد کنید';
                        }
                        return null;
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: context.dashBoardProvider.productOffPriceCtrl,
                      labelText: 'قیمت پیشنهادی',
                      inputType: TextInputType.number,
                      onSave: (val) {},
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: context.dashBoardProvider.productQntCtrl,
                      labelText: 'تعداد',
                      inputType: TextInputType.number,
                      onSave: (val) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً تعداد را وارد کنید';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(width: defaultPadding),
              Row(
                children: [
                  Expanded(child: _buildVariantTypeDropdown(context)),
                  Expanded(child: _buildVariantsMultiSelect(context)),
                ],
              ),
              SizedBox(height: defaultPadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: secondaryColor,
                    ),
                    onPressed: () {
                      context.dashBoardProvider.clearFields();
                      Navigator.of(context).pop();
                    },
                    child: Text('انصراف',              style: TextStyle(fontFamily: FONTS_STYLE_FAMILY),),
                  ),
                  SizedBox(width: defaultPadding),
                  Consumer<DashBoardProvider>(
                    builder: (context, p, _) {
                      final isBusy = p.isSubmitting;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: primaryColor,
                        ),
                        onPressed: isBusy
                            ? null
                            : () async {
                          final form = context.dashBoardProvider.addProductFormKey.currentState;
                          if (form == null) return;
                          if (!form.validate()) return;
                          form.save();

                          final ok = await context.dashBoardProvider.submitProduct();
                          if (!context.mounted) return;
                          if (ok) Navigator.of(context).pop();
                        },
                        child: isBusy
                            ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('ثبت',              style: TextStyle(fontFamily: FONTS_STYLE_FAMILY),),
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

  // تابع کمکی برای ساخت ImageCard
  Widget _buildImageCard(BuildContext context, int cardNumber, String label) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        File? selectedImage;
        switch (cardNumber) {
          case 1:
            selectedImage = dashProvider.selectedMainImage;
            break;
          case 2:
            selectedImage = dashProvider.selectedSecondImage;
            break;
          case 3:
            selectedImage = dashProvider.selectedThirdImage;
            break;
          case 4:
            selectedImage = dashProvider.selectedFourthImage;
            break;
          case 5:
            selectedImage = dashProvider.selectedFifthImage;
            break;
        }

        String? imageUrl;
        if (product?.images != null && product!.images!.isNotEmpty) {
          final imageIndex = cardNumber - 1;
          if (imageIndex < product!.images!.length) {
            imageUrl = product!.images![imageIndex].url;
          }
        }
        return ProductImageCard(
          labelText: label,
          imageFile: selectedImage,
          imageUrlForUpdateImage: imageUrl,
          onTap: () {
            dashProvider.pickImage(imageCardNumber: cardNumber);
          },
          onRemoveImage: () => dashProvider.markImageRemoved(cardNumber), // ← همین
        );

        // return ProductImageCard(
        //   labelText: label,
        //   imageFile: selectedImage,
        //   imageUrlForUpdateImage: imageUrl,
        //   onTap: () {
        //     dashProvider.pickImage(imageCardNumber: cardNumber);
        //   },
        //   // onRemoveImage: () {
        //   //   switch (cardNumber) {
        //   //     case 1:
        //   //       dashProvider.selectedMainImage = null;
        //   //       dashProvider.imgXFile1 = null;
        //   //       break;
        //   //     case 2:
        //   //       dashProvider.selectedSecondImage = null;
        //   //       dashProvider.imgXFile2 = null;
        //   //       break;
        //   //     case 3:
        //   //       dashProvider.selectedThirdImage = null;
        //   //       dashProvider.imgXFile3 = null;
        //   //       break;
        //   //     case 4:
        //   //       dashProvider.selectedFourthImage = null;
        //   //       dashProvider.imgXFile4 = null;
        //   //       break;
        //   //     case 5:
        //   //       dashProvider.selectedFifthImage = null;
        //   //       dashProvider.imgXFile5 = null;
        //   //       break;
        //   //   }
        //   //   dashProvider.updateUI();
        //   // },
        //   onRemoveImage: () => context.dashBoardProvider.markImageRemoved(cardNumber),
        //
        // );
      },
    );
  }

  // توابع کمکی برای dropdown ها
  Widget _buildCategoryDropdown(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        return Selector<DataProvider, List<Category>>(
          selector: (_, dp) => dp.categories,
          builder: (_, categories, __) {
            final items = List<Category>.from(categories)..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
            return CustomDropdown(
              key: ValueKey(dashProvider.selectedCategory?.sId),
              initialValue: dashProvider.selectedCategory,
              hintText: 'انتخاب دسته‌بندی',
              items: items,
              displayItem: (Category? category) => category?.name ?? '',
              onChanged: (newValue) {
                if (newValue != null) {
                  context.dashBoardProvider.filterSubcategory(newValue);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'لطفاً یک دسته‌بندی انتخاب کنید';
                }
                return null;
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSubCategoryDropdown(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        List<SubCategory> _sortedSubCategories = List.from(dashProvider.subCategoriesByCategory);
        _sortedSubCategories.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

        return CustomDropdown(
          key: ValueKey(dashProvider.selectedSubCategory?.sId),
          hintText: 'انتخاب زیر‌دسته',

          items: _sortedSubCategories,
          initialValue: dashProvider.selectedSubCategory,
          displayItem: (SubCategory? subCategory) => subCategory?.name ?? '',
          onChanged: (newValue) {
            if (newValue != null) {
              context.dashBoardProvider.filterBrand(newValue);
            }
          },
          validator: (value) {
            if (value == null) {
              return 'لطفاً یک زیر‌دسته انتخاب کنید';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildBrandDropdown(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        List<Brand> _sortedBrands = List.from(dashProvider.brandsBySubCategory);
        _sortedBrands.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

        return CustomDropdown(
          key: ValueKey(dashProvider.selectedBrand?.sId),
          initialValue: dashProvider.selectedBrand,
          items: _sortedBrands,
          hintText: 'انتخاب برند',

          displayItem: (Brand? brand) => brand?.name ?? '',
          onChanged: (newValue) {
            if (newValue != null) {
              dashProvider.selectedBrand = newValue;
              dashProvider.updateUI();
            }
          },
          validator: (value) {
            if (value == null) {
              return 'لطفاً برند را انتخاب کنید';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildVariantTypeDropdown(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        return Selector<DataProvider, List<VariantType>>(
          selector: (_, dp) => dp.variantTypes,
          builder: (_, types, __) {
            final items = List<VariantType>.from(types)..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
            return CustomDropdown(
              key: ValueKey(dashProvider.selectedVariantType?.sId),
              initialValue: dashProvider.selectedVariantType,
              items: items,
              displayItem: (VariantType? variantType) => variantType?.name ?? '',
              onChanged: (newValue) {
                if (newValue != null) {
                  context.dashBoardProvider.filterVariant(newValue);
                }
              },
              hintText: 'انتخاب نوع ویژگی',
            );
          },
        );
      },
    );
  }

  Widget _buildVariantsMultiSelect(BuildContext context) {
    return Consumer<DashBoardProvider>(
      builder: (context, dashProvider, child) {
        final filteredSelectedItems = dashProvider.selectedVariants
            .where((item) => dashProvider.variantsByVariantType.contains(item))
            .toList();

        return MultiSelectDropDown(
          items: dashProvider.variantsByVariantType,
          onSelectionChanged: (newValue) {
            dashProvider.selectedVariants = newValue;
            dashProvider.updateUI();
          },
          displayItem: (String item) => item,
          selectedItems: filteredSelectedItems,
        );
      },
    );
  }
}

// Popup
void showAddProductForm(BuildContext context, Product? product) {
  showDialog(
    context: context,
    barrierDismissible: false, // مثل دسته‌بندی
    builder: (BuildContext context) {
      final isEdit = product != null;
      return AlertDialog(
        backgroundColor: bgColor,
        title: Center(
          child: Text(
            (isEdit ? 'ویرایش محصول' : 'افزودن محصول').toUpperCase(),
            style: const TextStyle(color: primaryColor,fontFamily: FONTS_STYLE_FAMILY),
          ),
        ),
        content: ProductSubmitForm(product: product),
      );
    },
  ).then((_) {
    context.dashBoardProvider.clearFields(); // پاکسازی مثل دسته‌بندی
  });
}
