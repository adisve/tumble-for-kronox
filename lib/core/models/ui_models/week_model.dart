import 'package:tumble/core/models/backend_models/schedule_model.dart';

class Week {
  final int weekNumber;
  final List<Day> days;

  Week({required this.weekNumber, required this.days});

  factory Week.fromEventList(int weekNumber, List<Day> days) {
    return Week(weekNumber: weekNumber, days: days);
  }
}
