import 'dart:io';

import 'package:flutter/material.dart';
import 'settings.dart';
import 'help_page.dart';

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

    List<DropdownMenuItem<Templates>> formatItems = [];

    for (var t in Templates.values) {
      formatItems.add(DropdownMenuItem(child: Text(t.name), value: t));
    }

    List<Widget> list = [
      ListTile(
          leading: const Text("Username"),
          title: TextFormField(
              initialValue: settings.username,
              onChanged: (value) => settings.username = value.trim()
          )
      ),
      ListTile(
          leading: const Text("Password"),
          title: TextFormField(
              initialValue: settings.password,
              onChanged: (value) => settings.password = value.trim()
          )
      ),
      ListTile(
          leading: const Text("Body Template"),
          title: DropdownButton(items: formatItems,
              value: settings.template,
              onChanged: (Templates? value) {
                setState(() {
                  settings.template = value!;
                });
              })
      ),
      ListTile(
          leading: const Text("Destination Email"),
          title: TextFormField(
              initialValue: settings.customDestinationEmail,
              onChanged: (value) => settings.customDestinationEmail = value.trim()
          )
      ),
      ListTile(
          leading: const Text("Subject Template"),
          title: TextFormField(
              initialValue: settings.subject,
              onChanged: (value) => settings.subject = value.trim()
          )
      ),
      ListTile(
          leading: const Text("Custom Template"),
          title: TextFormField(
              initialValue: settings.customTemplate,
              onChanged: (value) => settings.customTemplate = value
          )
      ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(onPressed: () {showHelpPage();}, icon:const Icon(Icons.help))
        ],
      ),
      body: ListView(children: list)
    );
  }

  showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return HelpPage();
    }));
  }
}
