import 'package:admin/screens/dashboard/menu/side_menu.dart';
import 'package:flutter/material.dart';
import '../../../utility/constants.dart';




class SideMenuCard extends StatefulWidget {
  const SideMenuCard({super.key});

  @override
  State<SideMenuCard> createState() => _SideMenuCardState();
}

class _SideMenuCardState extends State<SideMenuCard> {
  late final ScrollController _sideCtrl;

  @override
  void initState() {
    super.initState();
    _sideCtrl = ScrollController();
  }

  @override
  void dispose() {
    _sideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: defaultPadding, top: defaultPadding,
        bottom: defaultPadding, right: defaultPadding,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Scrollbar(
            controller: _sideCtrl,     // 👈 به Scrollbar
            thumbVisibility: true,
            child: SideMenu(controller: _sideCtrl), // 👈 به ListView
          ),
        ),
      ),
    );
  }
}
