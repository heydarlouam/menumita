
import 'package:admin/utility/debouncer.dart';
import 'package:admin/utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utility/constants.dart';

class DashBoardHeader extends StatelessWidget {
  const DashBoardHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [


        Text(
          "داشبورد",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily:FONTS_STYLE_FAMILY,
          ),
        ),
        SizedBox(width: 10,),
        // Spacer(flex: 1),
        Expanded(
          child: SearchField(
            onChange: (val) {
              context.dataProvider.filterProducts(val);
            },
          ),
        ),
        //  ProfileCard()
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
        hintStyle: TextStyle(fontFamily: FONTS_STYLE_FAMILY),
        hintText: "جستجو",
        suffixStyle: TextStyle(fontFamily: FONTS_STYLE_FAMILY),
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
           // margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
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
