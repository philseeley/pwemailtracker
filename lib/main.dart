import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share/share.dart';
import 'package:location/location.dart';
import 'package:latlong_formatter/latlong_formatter.dart';
import 'settings.dart';
import 'settings_page.dart';

void main() => runApp(const PWEmailTracker());

class PWEmailTracker extends StatelessWidget {
  const PWEmailTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Email Tracker',
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

  final Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;
  LocationData? locationData;
  // These default formatters will be overwritten after settings have been loaded.
  LatLongFormatter bodyFormatter = LatLongFormatter('');
  LatLongFormatter subjectFormatter = LatLongFormatter('');

  String subject = '';
  String body = '';

  String? msg;

  _MainState() {
    loadSettings();
  }

  loadSettings() async {
    settings = await Settings.load();
    setFormatters();

    setState(() {});
  }

  listenLocation() async {
    while(locationSubscription == null) {
      try {
        PermissionStatus permStatus = await location.requestPermission();

        if ([PermissionStatus.granted, PermissionStatus.grantedLimited].contains(permStatus)) {
          if (await location.serviceEnabled()) {
            locationSubscription ??=
                location.onLocationChanged.listen(getLocation);
            msg = null;
          } else {
            setState(() {
              msg = "Location is disabled";
            });
          }
        } else {
          setState(() {
            msg = "Location permission denied. Please allow";
          });
        }

        break;
      } on Exception {
        msg = 'Waiting for Location service';
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  void cancelLocation() {
    locationSubscription?.cancel();
    locationSubscription = null;
  }

  @override
  void initState() {
    super.initState();
    listenLocation();
    WidgetsBinding.instance.addObserver(this);
  }

  getLocation(LocationData loc) {
    setState(() {
      locationData = loc;
      msg = null;
    });
  }

  @override
  void dispose() {
    cancelLocation();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch(state)
    {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        settings?.save();
        cancelLocation();

        setState(() {
          locationData = null;
        });

        break;
      case AppLifecycleState.resumed:
        listenLocation();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    if(settings != null) {
      if (settings!.firstUse) {
        list.add(ListTile(
            leading: const Text("Please review Settings before first use"),
            title: IconButton(onPressed: () => showSettingsPage(),
                icon: const Icon(Icons.settings))));
      }

      if (locationData != null &&
          ((locationData?.accuracy?.round())! <= (settings!.accuracy.round()))) {
        cancelLocation();

        subject = subjectFormatter.format(
            LatLong(locationData!.latitude!, locationData!.longitude!),
            info: settings!.info);
        body = bodyFormatter.format(
            LatLong(locationData!.latitude!, locationData!.longitude!),
            info: settings!.info);

        list.add(ListTile(
            title: Text(
                "Location acquired to ${locationData?.accuracy?.round()}m"),
            trailing: IconButton(
                onPressed: refreshLocation, icon: const Icon(Icons.refresh))));

        if (subject.isNotEmpty) {
          list.add(ListTile(title: Text("Subject: $subject")));
        }

        list.add(ListTile(title: Text(body)));
        list.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(onPressed: sendEmail,
              icon: const Icon(Icons.email),
              iconSize: 64.0),
          IconButton(
              onPressed: share, icon: const Icon(Icons.share), iconSize: 64.0)
        ]));
      } else {
        list.add(ListTile(title: Text(msg ??
            'Waiting for accurate Location${(locationData != null)
                ? ": ${locationData?.accuracy?.round()}m"
                : ""}')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Email Tracker"), actions: [IconButton(onPressed: () {showSettingsPage();}, icon:const Icon(Icons.settings))]),
      body: Column(children: list)
    );
  }

  showSettingsPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
        return SettingsPage(settings!);
      }));

    setState(() {
      try {
        setFormatters();
      } catch (e) {
        showError(context, e.toString());
      }
      settings!.firstUse = false;
    });
  }

  setFormatters() {
    try {
      bodyFormatter = LatLongFormatter(settings!.template.bodyTemplate ?? settings!.bodyTemplate);
    } catch (e) {
      showError(context, e.toString());
      bodyFormatter = LatLongFormatter('');
    }
    try {
      subjectFormatter =
          LatLongFormatter(settings!.template.subjectTemplate ?? settings!.subjectTemplate);
    } catch (e) {
      showError(context, e.toString());
      bodyFormatter = LatLongFormatter('');
    }
  }

  void refreshLocation() {
    setState(() {
      locationData = null;
    });

    listenLocation();
  }

  void sendEmail() async {
    List<String> recipients = settings!.template.destinationEmails??settings!.emailsAddresses;

    final Email email = Email(
      body: body,
      subject: subject,
      recipients: recipients,
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } on PlatformException catch (e) {
      if (Platform.isIOS && e.code == 'not_available') {
        showError(context, 'On iOS you must install and configure the Apple EMail App with an account.');
      }
      else {
        showError(context, "Please screenshot this error and send to the developer: $e");
      }
    }

    // The iOS guidelines prohibit the auto-closing of apps.
    if (!Platform.isIOS && settings!.autoClose) {
      SystemNavigator.pop();
    }
  }

  void share() async {
    String s = subject.isNotEmpty ? "$subject\n\n" : "";
    await Share.share("$s$body");

    // The iOS guidelines prohibit the auto-closing of apps.
    if (!Platform.isIOS && settings!.autoClose) {
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
