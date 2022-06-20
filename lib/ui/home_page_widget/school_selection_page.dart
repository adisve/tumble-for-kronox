import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tumble/models/ui_models/school_model.dart';
import 'package:tumble/ui/home_page_widget/cubit/home_page_cubit.dart';
import 'package:tumble/ui/main_app_widget/cubit/main_app_cubit.dart';
import 'package:tumble/ui/search_page_widgets/school_card.dart';
import 'package:tumble/ui/search_page_widgets/search/schedule_search_page.dart';

class SchoolSelectionPage extends StatefulWidget {
  final List<School>? schoolsList;
  const SchoolSelectionPage({Key? key, this.schoolsList}) : super(key: key);

  @override
  State<SchoolSelectionPage> createState() => _SchoolSelectionPageState();
}

class _SchoolSelectionPageState extends State<SchoolSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.background,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: Text(
                    "Choose your school",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 26,
                    ),
                  ),
                ),
                Column(
                  children: widget.schoolsList!
                      .map((school) => SchoolCard(
                            schoolName: school.schoolName,
                            schoolId: school.schoolId,
                            schoolLogo: school.schoolLogo,
                            onTap: () {
                              context
                                  .read<MainAppCubit>()
                                  .setup(school.schoolName);
                              Navigator.of(context).pushAndRemoveUntil(
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          const ScheduleSearchPage()),
                                  (Route<dynamic> route) => false);
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          )),
    );
  }
}
