import 'package:admin/utility/extensions.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/variant.dart';

import '../../../utility/constants.dart';
import 'add_variant_form.dart';


class VariantsListSection extends StatelessWidget {
  const VariantsListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      width: double.infinity,
      child: DataTable(
        columnSpacing: defaultPadding,
        columns: const [
          DataColumn(label: Text('Variant Name')),
          DataColumn(label: Text('Variant Type')),
          DataColumn(label: Text('Edit')),
          DataColumn(label: Text('Delete')),
        ],
        rows: List.generate(
          data.variants.length,
              (i) {
            final Variant item = data.variants[i];
            return DataRow(
              cells: [
                DataCell(Text(item.name ?? '')),
                DataCell(Text(item.variantTypeId?.name ?? '')),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => showAddVariantForm(context, item),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => context.variantProvider.deleteVariant(item),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

