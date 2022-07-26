import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tumble/models/api_models/schedule_model.dart';
import 'package:tumble/ui/home_page_widget/schedule_view_widgets/event_details/event_details_page.dart';
import 'package:tumble/ui/home_page_widget/schedule_view_widgets/tumble_list_view/tumble_list_view_schedule_card.dart';

class TumbleListViewDayContainer extends StatelessWidget {
  final Day day;
  const TumbleListViewDayContainer({
    Key? key,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text("${day.name} ${day.date}",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground, fontSize: 17, fontWeight: FontWeight.w400)),
              Expanded(
                  child: Divider(
                color: Theme.of(context).colorScheme.onBackground,
                indent: 6,
                thickness: 1,
              ))
            ],
          ),
          Column(
            children: day.events
                .map((event) => ScheduleCard(
                    title: event.title,
                    course: event.course,
                    teachers: event.teachers,
                    locations: event.locations,
                    color: "#cccccc",
                    timeStart: event.timeStart,
                    timeEnd: event.timeEnd,
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(builder: (context) => EventDetailsPage(event: event)));
                    }))
                .toList(),
          )
        ],
      ),
    );
  }
}
