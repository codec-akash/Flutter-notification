import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

// import 'package:date_time_picker/date_time_picker.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();
  var androidinitialize = AndroidInitializationSettings("app_icon");
  var intializeSettings = InitializationSettings(android: androidinitialize);
  await flutterLocalNotificationsPlugin.initialize(intializeSettings,
      onSelectNotification: (payload) async {
    if (payload != null) {
      print(payload);
    }
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  // final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  // tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> dateTime = [];

  @override
  void initState() {
    super.initState();
  }

  // void showNotification() async {
  //   var androidDetails = AndroidNotificationDetails(
  //       "channelId", "channelName", "channelDescription");
  //   var notificationSettings = NotificationDetails(android: androidDetails);
  //   await flutterLocalNotificationsPlugin.show(
  //       0, "title", "body", notificationSettings);
  // }

  void scheduleNotification() async {
    var androidDetails = AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription");
    var notificationDetails = NotificationDetails(android: androidDetails);
    for (int i = 0; i < dateTime.length; i++) {
      if (tz.TZDateTime.parse(tz.local, dateTime[i]).isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.zonedSchedule(i, "title", "body",
            tz.TZDateTime.parse(tz.local, dateTime[i]), notificationDetails,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true);
      } else {
        print("LoL");
      }
    }
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     0,
    //     "title",
    //     "body",
    //     tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    //     notificationDetails,
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.wallClockTime,
    //     androidAllowWhileIdle: true);
  }

  void _incrementCounter() {
    print('Clickled');
    setState(() {
      _counter++;
    });
    scheduleNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            // DateTimePicker(
            //   type: DateTimePickerType.time,
            //   use24HourFormat: false,
            //   firstDate: DateTime.now(),
            //   onChanged: (newValue) {
            //     setState(() {
            //       dateTime.add(newValue);
            //       print(newValue);
            //     });
            //   },
            // ),
            FlatButton(
              child: Text('Lmao'),
              onPressed: () => DatePicker.showDateTimePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(2020),
                maxTime: DateTime(2021),
                currentTime: DateTime.now(),
                onConfirm: (time) {
                  setState(() {
                    dateTime.add(time.toIso8601String());
                  });
                  scheduleNotification();
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: dateTime.length ?? 0,
                itemBuilder: (context, index) => Text(dateTime[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
