import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tumble/core/theme/data/colors.dart';
import 'package:tumble/core/ui/main_app_widget/data/labels.dart';
import 'package:tumble/core/ui/main_app_widget/main_app_bottom_nav_bar/cubit/bottom_nav_cubit.dart';

typedef ChangePageCallBack = void Function(int index);

class TumbleNavigationBar extends StatelessWidget {
  final ChangePageCallBack? onTap;
  const TumbleNavigationBar({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainAppNavigationCubit, MainAppNavigationState>(
      builder: (context, mainappstate) {
        return DotNavigationBar(
          marginR: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          boxShadow: [
            BoxShadow(
                color: Colors.black87.withOpacity(.15),
                spreadRadius: 5.9,
                blurRadius: 20),
          ],
          itemPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          currentIndex: mainappstate.index,
          onTap: onTap,
          dotIndicatorColor: CustomColors.orangePrimary,
          borderRadius: 15,
          items: [
            DotNavigationBarItem(
              icon: const Icon(CupertinoIcons.search),
              selectedColor: CustomColors.orangePrimary,
            ),
            DotNavigationBarItem(
              icon: const Icon(CupertinoIcons.collections),
              selectedColor: CustomColors.orangePrimary,
            ),
            DotNavigationBarItem(
              icon: const Icon(CupertinoIcons.list_bullet_indent),
              selectedColor: CustomColors.orangePrimary,
            ),
            DotNavigationBarItem(
              icon: const Icon(CupertinoIcons.calendar),
              selectedColor: CustomColors.orangePrimary,
            ),
            DotNavigationBarItem(
              icon: const Icon(CupertinoIcons.person),
              selectedColor: CustomColors.orangePrimary,
            ),
          ],
        );
      },
    );
  }
}
