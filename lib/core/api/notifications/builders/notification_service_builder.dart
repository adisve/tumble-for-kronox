import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tumble/core/api/dependency_injection/get_it.dart';
import 'package:tumble/core/api/preferences/repository/preference_repository.dart';
import 'package:tumble/core/extensions/extensions.dart';
import 'package:tumble/core/api/notifications/interface/inotification_service_builder.dart';
import 'package:tumble/core/theme/data/colors.dart';

///
/// Implementation of [INotificationServiceBuilder] interface,
/// invoking methods which are meant to create a notification
/// at a scheduled time, as well as dynamically allocate channels for
/// invoking any notifications.
///
class NotificationServiceBuilder implements INotificationServiceBuilder {
  final Color defaultColor = CustomColors.orangePrimary;
  final String defaultIcon = "resource://drawable/res_tumble_app_logo";
  final _awesomeNotifications = getIt<AwesomeNotifications>();
  final _preferenceService = getIt<PreferenceRepository>();

  @override
  NotificationChannel buildNotificationChannel({
    required String channelKey, // Schedule ID
    required String channelName, // name of schedule in readable text
    required String channelDescription, // short description passed to navigator
  }) =>
      NotificationChannel(
        channelKey: channelKey,
        channelName: channelName,
        channelDescription: channelDescription,
        defaultColor: defaultColor,
      );

  @override
  Future<bool> buildOffsetNotification(
          {required int id,
          required String channelKey,
          required String groupkey,
          required String title,
          required String body,
          required DateTime date}) =>
      _awesomeNotifications.createNotification(
          content: NotificationContent(
              id: id,
              channelKey: channelKey, // Schedule id
              groupKey: groupkey, //Schedule course
              title: title.capitalize(),
              icon: defaultIcon,
              color: defaultColor,
              body: body,
              wakeUpScreen: true,
              notificationLayout: NotificationLayout.Default,
              category: NotificationCategory.Reminder),
          actionButtons: [
            NotificationActionButton(key: 'VIEW', label: 'View'),
          ],
          schedule: NotificationCalendar.fromDate(
              date: date.subtract(Duration(minutes: _preferenceService.notificationOffset!)).toLocal(),
              allowWhileIdle: true,
              preciseAlarm: true));

  @override
  Future<bool> buildExactNotification(
          {required int id,
          required String channelKey,
          required String groupkey,
          required String title,
          required String body,
          required DateTime date}) =>
      _awesomeNotifications.createNotification(
          content: NotificationContent(
              id: id,
              channelKey: channelKey, // Schedule id
              groupKey: groupkey, //Schedule course
              title: title.capitalize(),
              icon: defaultIcon,
              color: defaultColor,
              body: body,
              wakeUpScreen: true,
              notificationLayout: NotificationLayout.Default,
              category: NotificationCategory.Reminder),
          actionButtons: [
            NotificationActionButton(key: 'VIEW', label: 'View'),
          ],
          schedule: NotificationCalendar.fromDate(date: date.toLocal(), allowWhileIdle: true, preciseAlarm: true));
}
