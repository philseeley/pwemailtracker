import 'dart:io';

import 'package:flutter/services.dart';
import 'package:format/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share/share.dart';
import 'package:location/location.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  late Settings settings;

  Location location = Location();
  LocationData? locationData;
  late LatLongFormatter bodyFormatter;
  late LatLongFormatter subjectFormatter;

  String subject = '';
  String body = '';

  _MainState() {
    init();
  }

  init() async {
    settings = await Settings.load();

    if(await location.serviceEnabled()) {
      location.onLocationChanged.listen(getLocation);
    } else {
      Fluttertoast.showToast(msg: "Location is disabled", toastLength: Toast.LENGTH_LONG);
    }

    setFormatters();
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
        settings.save();

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

    if (locationData != null && ((locationData?.accuracy?.round())! <= (settings.accuracy.round()))) {
      subject = subjectFormatter.format(LatLong(locationData!.latitude!, locationData!.longitude!), info: settings.info);
      body = bodyFormatter.format(LatLong(locationData!.latitude!, locationData!.longitude!), info: settings.info);

      if(settings.firstUse) {
        list.add(ListTile(leading: const Text("Please review Settings before first use"), title: IconButton(onPressed: () => showSettingsPage(), icon: const Icon(Icons.settings))));
      }

      list.add(ListTile(title: Text("Location acquired to ${locationData?.accuracy?.round()}m")));
      if(subject.isNotEmpty) {
        list.add(ListTile(title: Text("Subject: $subject")));
      }
      list.add(ListTile(title: Text(body)));
      list.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(onPressed: sendEmail, icon: const Icon(Icons.email), iconSize: 64.0),
        IconButton(onPressed: share, icon: const Icon(Icons.share), iconSize: 64.0)
      ]));
    } else {
      list.add(ListTile(title: Text(format("Waiting for accurate Location{}", (locationData != null) ? ": ${locationData?.accuracy?.round()}m" : ""))));
      body = '';
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Email Tracker"), actions: [IconButton(onPressed: () {showSettingsPage();}, icon:const Icon(Icons.settings))]),
      body: Column(children: list)
    );
  }

  showSettingsPage () async {

    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
        return SettingsPage(settings);
      }));

    setState(() {
      try {
        setFormatters();
      } catch (e) {
        showError(context, e.toString());
      }
      settings.firstUse = false;
    });
  }

  setFormatters() {
    try {
      bodyFormatter = LatLongFormatter(settings.template.bodyTemplate ?? settings.bodyTemplate);
    } catch (e) {
      showError(context, e.toString());
      bodyFormatter = LatLongFormatter('');
    }
    try {
      subjectFormatter =
          LatLongFormatter(settings.template.subjectTemplate ?? settings.subjectTemplate);
    } catch (e) {
      showError(context, e.toString());
      bodyFormatter = LatLongFormatter('');
    }
  }

  void sendEmail() async {
    List<String> recipients = settings.template.destinationEmails??settings.destinationEmails;

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
        showError(context, "Please screenshot this error and send to the developer: "+e.toString());
      }
    }

    // The iOS guidelines prohibit the auto-closing of apps.
    if (!Platform.isIOS && settings.autoClose) {
      SystemNavigator.pop();
    }
  }

  void share() async {
    await Share.share("$subject\n\n$body");

    // The iOS guidelines prohibit the auto-closing of apps.
    if (!Platform.isIOS && settings.autoClose) {
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
