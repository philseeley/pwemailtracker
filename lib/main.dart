import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:format/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:location/location.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'settings.dart';
import 'settings_page.dart';

void main() => runApp(const PWEmailTracker());

class PWEmailTracker extends StatelessWidget {
  const PWEmailTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Predict Wind Email Tracker',
      home: _Main(),
      debugShowCheckedModeBanner: false
    );
  }
}

class _Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<_Main> with WidgetsBindingObserver {

  Settings? settings;

  Location location = Location();
  LocationData? locationData;

  double progressValue = 0.0;

  _MainState() {
    init();
  }

  init() async {
    settings ??= await Settings.load();

    if(await location.serviceEnabled()) {
      location.onLocationChanged.listen(getLocation);
    } else {
      Fluttertoast.showToast(msg: "Location is disabled", toastLength: Toast.LENGTH_LONG);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  getLocation(LocationData loc) {
    setState(() {
      locationData = loc;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state)
    {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        settings?.save();

        setState(() {
          locationData = null;
        });

        break;
      case AppLifecycleState.resumed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(ListTile(leading: const Text("Email:"), title: Text(settings?.email ?? "Please set your email address in Settings")));

    if (locationData != null && ((locationData?.accuracy?.round())! <= (settings?.accuracy.round())!)) {
      list.add(ListTile(title: Text("Location acquired to ${locationData?.accuracy?.round()}m")));
      if (settings?.email != null) {
        list.add(ListTile(title: IconButton(onPressed: sendEmail, icon: const Icon(Icons.email), iconSize: 64.0)));
      }
    } else {
      list.add(ListTile(title: Text(format("Waiting for accurate Location{}", (locationData != null) ? " - ${locationData?.accuracy?.round()}m" : ""))));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Predict Wind Email Tracker"), actions: [IconButton(onPressed: () {showSettingsPage();}, icon:const Icon(Icons.settings))]),
      body: Column(children: list)
    );
  }

  showSettingsPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
        return SettingsPage(settings!);
      }));

    setState(() {});
  }
  
  void sendEmail() async {
    DateTime now = DateTime.now();
    String dt = DateFormat('yyyy-MM-dd HH:mm').format(now);

    final Email email = Email(
      body: '${settings?.email} ${locationData?.latitude} ${locationData?.longitude} $dt${format('{:+03d}{:02d}', now.timeZoneOffset.inHours, now.timeZoneOffset.inMinutes%60)}',
      subject: '',
      recipients: ['tracking@predictwind.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } on PlatformException catch (e) {
      if (Platform.isIOS && e.code == 'not_available') {
        showError(context, 'On iOS you must install and configure the Apple EMail App with an account.');
      }
      else {
        showError(context, "Please screenshot this error and send to the developer: "+e.toString());
      }
    }

    if (settings!.autoClose) {
      SystemNavigator.pop();
    }
  }
}

void showError(BuildContext context, String error) {
  showDialog(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(error),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            }
          )]
      );
    },
  );
}
