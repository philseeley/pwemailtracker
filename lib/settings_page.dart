import 'dart:io';

import 'package:flutter/material.dart';
import 'settings.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  const SettingsPage(this.settings, {Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    Settings settings = widget.settings;

    List<DropdownMenuItem<CoordFormat>> formatItems = [];

    formatItems.add(DropdownMenuItem(child: Text(CoordFormat.decimalDegrees.name), value: CoordFormat.decimalDegrees));
    formatItems.add(DropdownMenuItem(child: Text(CoordFormat.decimalMinutes.name), value: CoordFormat.decimalMinutes));
    formatItems.add(DropdownMenuItem(child: Text(CoordFormat.degreesMinutesSeconds.name), value: CoordFormat.degreesMinutesSeconds));

    List<Widget> list = [
      ListTile(
          leading: const Text("Identification"),
          title: TextFormField(
              initialValue: settings.ident,
              onChanged: (value) => settings.ident = value.isNotEmpty ? value.trim() : null
          )
      ),
      ListTile(
          leading: const Text("Destination Email"),
          title: TextFormField(
              initialValue: settings.destinationEmail,
              onChanged: (value) => settings.destinationEmail = value.trim()
          )
      ),
      ListTile(
          leading: const Text("Position Format"),
          title: DropdownButton(items: formatItems,
                                value: settings.coordFormat,
                                onChanged: (CoordFormat? value) {
                                  setState(() {
                                    settings.coordFormat = value!;
                                  });
                                })
      ),
      SwitchListTile(title: const Text("Cardinal Format"),
          value: settings.cardinalFormat,
          onChanged: (bool value) {
            setState(() {
              settings.cardinalFormat = value;
            });
          }
      ),
      SwitchListTile(title: const Text("Include Date/Time"),
          value: settings.includeDateTime,
          onChanged: (bool value) {
            setState(() {
              settings.includeDateTime = value;
            });
          }
      )
    ];

    // The iOS guidelines prohibit the auto-closing of apps.
    if (!Platform.isIOS) {
      list.add(
        SwitchListTile(title: const Text("Auto Close"),
          value: settings.autoClose,
          onChanged: (bool value) {
            setState(() {
              settings.autoClose = value;
            });
          }));
    }

    list.add(
      ListTile(
        leading: const Text("Accuracy"),
        title: Slider(
          min: 5.0,
          max: 100.0,
          divisions: 19,
          value: settings.accuracy,
          label: "${settings.accuracy}",
          onChanged: (double value) {
            setState(() {
              settings.accuracy = value;
            });
          }),
      ));

    list.add(
      // ListTile(leading: const Text('Instructions'),
      //   title: Text('For Predict Wind email tracking the "Auth Email" is required '
      //       'to be your account address, but emails can be sent from any email address. '''
      //       'The date/time is also required and a "Position Format" of '
      //       '"${CoordFormat.decimalDegrees.name}" is recommended.'
      //       'The "Cardinal Format" uses N/S and E/W instead of +/- values.'))
        ListTile(title: Text(
'''For Predict Wind email tracking the "Identification" is required to be your account email address, but emails can be sent from any address.

The date/time is also required and a non-Cardinal "Position Format" of "${CoordFormat.decimalDegrees.name}" is recommended.

The "Cardinal Format" uses N/S and E/W instead of +/- values.'''))
    );

    return(Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(children: list)
    ));
  }
}
