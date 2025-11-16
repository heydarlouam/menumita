

import 'package:admin/utility/debouncer.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utility/constants.dart';

class VariantsHeader extends StatelessWidget {
  const VariantsHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "ویژگی‌ها",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      //  Spacer(flex: 2),
        SizedBox(width: 10,),
        Expanded(
          child: SearchField(
            onChange: (val) {
              context.dataProvider.filterVariants(val);
            },
          ),
        ),
       // ProfileCard(),
      ],
    );
  }
}


class SearchField extends StatefulWidget {
  final Function(String) onChange;

  const SearchField({
    Key? key,
    required this.onChange,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final Debouncer _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debouncer(const Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "جستجو",
        fillColor: secondaryColor,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(defaultPadding * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
      onChanged: (value) {
        _debounce(() => widget.onChange(value));
      },
    );
  }
}
