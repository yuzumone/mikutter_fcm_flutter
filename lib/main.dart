import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'model/mikutter_message.dart';
import 'database/mikutter_message_provider.dart';

final dbPath = 'mikutter_message_db';
FirebaseMessaging _messaging;
String _token = 'default';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: <String, WidgetBuilder>{
        '/settings': (_) => new SettingPage(title: 'Setting'),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class SettingPage extends StatefulWidget {
  SettingPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  MikutterMessageProvider _provider = new MikutterMessageProvider();

  @override
  void initState() {
    super.initState();
    _provider.open(dbPath);
    _messaging = new FirebaseMessaging();
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var data = message['data'];
        var msg = MikutterMessage(
          title: data['title'],
          body: data['body'],
          url: data['url'],
        );
        _provider.insert(msg);
        _provider.close();
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'default', 'Notification', 'mikuter fcm notification');
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0, msg.title, msg.body, platformChannelSpecifics,
            payload: json.encode(data));
      },
      onLaunch: (Map<String, dynamic> message) async {},
      onResume: (Map<String, dynamic> message) async {},
    );
    _messaging.getToken().then((String token) {
      setState(() {
        _token = token;
      });
    });
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIos = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIos);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      var data = json.decode(payload);
      var msg = MikutterMessage.fromMap(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
    );
  }
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () {
            var data = ClipboardData(text: _token);
            Clipboard.setData(data);
            Fluttertoast.showToast(
              msg: 'Copy token',
            );
          },
          child: Text(
            _token,
          ),
        ),
      ),
    );
  }
}
