import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:format/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:share/share.dart';
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

  String body = '';

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

    if (locationData != null && ((locationData?.accuracy?.round())! <= (settings?.accuracy.round())!)) {
      body = getBody();

      if(settings!.firstUse) {
        list.add(ListTile(leading: const Text("Please review Settings before first use"), title: IconButton(onPressed: () => showSettingsPage(), icon: const Icon(Icons.settings))));
      }

      list.add(ListTile(title: Text("Location acquired to ${locationData?.accuracy?.round()}m")));
      list.add(ListTile(title: Text(body)));
      list.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(onPressed: sendEmail, icon: const Icon(Icons.email), iconSize: 64.0),
        IconButton(onPressed: share, icon: const Icon(Icons.share), iconSize: 64.0)
      ]));
    } else {
      list.add(ListTile(title: Text(format("Waiting for accurate Location{}", (locationData != null) ? " - ${locationData?.accuracy?.round()}m" : ""))));
      body = '';
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

    setState(() {
      settings?.firstUse = false;
    });
  }
  
  String getBody() {
    DateTime now = DateTime.now();
    String dt = DateFormat('yyyy-MM-dd HH:mm').format(now);

    String northSouth = locationData!.latitude! < 0 ? 'S' : 'N';
    String westEast = locationData!.longitude! < 0 ? 'W' : 'E';

    String coords = '${locationData?.latitude!.toStringAsFixed(5)} ${locationData?.longitude!.toStringAsFixed(5)}';

    if(settings!.cardinalFormat) {
      coords = '${locationData?.latitude!.abs().toStringAsFixed(5)} $northSouth ${locationData?.longitude!.abs().toStringAsFixed(5)} $westEast';
    }

    if (settings?.coordFormat != CoordFormat.decimalDegrees) {
      int latDegrees = locationData!.latitude!.toInt();
      double latMinutes = 60 * locationData!.latitude!.remainder(latDegrees).abs();

      int lonDegrees = locationData!.longitude!.toInt();
      double lonMinutes = 60 * locationData!.longitude!.remainder(lonDegrees).abs();

      coords = '$latDegrees ${latMinutes.toStringAsFixed(3)} $lonDegrees ${lonMinutes.toStringAsFixed(3)}';

      if (settings!.cardinalFormat) {
        coords = '${latDegrees.abs()} ${latMinutes.toStringAsFixed(3)} $northSouth ${lonDegrees.abs()} ${lonMinutes.toStringAsFixed(3)} $westEast';
      }

      if (settings?.coordFormat == CoordFormat.degreesMinutesSeconds) {
        double latSeconds = 60 * latMinutes.remainder(latMinutes.toInt());
        double lonSeconds = 60 * lonMinutes.remainder(lonMinutes.toInt());

        coords = '$latDegrees ${latMinutes.toInt()} ${latSeconds.toStringAsFixed(2)} $lonDegrees ${lonMinutes.toInt()} ${lonSeconds.toStringAsFixed(2)}';

        if (settings!.cardinalFormat) {
          coords = '${latDegrees.abs()} ${latMinutes.toInt()} ${latSeconds.toStringAsFixed(2)} $northSouth ${lonDegrees.abs()} ${lonMinutes.toInt()} ${lonSeconds.toStringAsFixed(2)} $westEast';
        }
      }
    }

    String body = '';
    if(settings?.ident != null) {
      body += '${settings?.ident} ';
    }
    body += coords;

    if(settings!.includeDateTime) {
      body += ' $dt${format('{:+03d}{:02d}', now.timeZoneOffset.inHours, now.timeZoneOffset.inMinutes%60)}';
    }

    return body;
  }

  void sendEmail() async {

    List<String> recipients = [];
    if(settings!.destinationEmail.isNotEmpty) {
      recipients.add(settings!.destinationEmail);
    }

    final Email email = Email(
      body: body,
      subject: '',
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
    if (!Platform.isIOS && settings!.autoClose) {
      SystemNavigator.pop();
    }
  }

  void share() {
    Share.share(body);
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
