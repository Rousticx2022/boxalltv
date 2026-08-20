import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  requestNotificationPermissionIOS() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    return;
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    return;
  }

  Future<void> init() async {
    //Initialization Settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logo');

    if (Platform.isIOS) {
      requestNotificationPermissionIOS();
    }

    //Initialization Settings for iOS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    //InitializationSettings for initializing settings for both platforms (Android & iOS)
    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse
        // onSelectNotification: selectNotification,
        );
  }

  static const AndroidNotificationDetails _androidNotificationDetails =
      AndroidNotificationDetails(
    '0',
    'myChannel',
    playSound: true,
    priority: Priority.high,
    importance: Importance.high,
    color: Colors.white,
    enableLights: true,
  );

  Future<void> showNotifications(String? title, String? body) async {
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: _androidNotificationDetails),
      payload: 'Notification Payload',
    );
  }

  void selectNotification(String? payload) async {}
}
