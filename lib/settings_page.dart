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

    list.addAll([
      ListTile(
          leading: const Text("Identity"),
            title: TextFormField(
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: null,
            initialValue: settings.ident.join('\n'),
            onChanged: (value) => settings.ident = value.trim().split('\n')
          )
      ),
      ListTile(
          leading: const Text("Template"),
          title: DropdownButton(items: formatItems,
              value: settings.template,
              onChanged: (Templates? value) {
                setState(() {
                  settings.template = value!;
                });
              }),
          trailing: settings.template == Templates.custom ? null : IconButton(
            onPressed: () {copyTemplate();},
            icon:const Icon(Icons.copy))
      ),
      ListTile(
          leading: const Text("Destination Emails"),
          title: TextFormField(
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: null,
            initialValue: settings.destinationEmails.join('\n'),
            onChanged: (value) => settings.destinationEmails = value.trim().split('\n')
          )
      ),
      ListTile(
          leading: const Text("Subject Template"),
          title: TextFormField(
            enabled: settings.template == Templates.custom,
            initialValue: settings.subjectTemplate,
            onChanged: (value) => settings.subjectTemplate = value.trim()
          )
      ),
      ListTile(
          leading: const Text("Body Template"),
          title: TextFormField(
            enabled: settings.template == Templates.custom,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: null,
            initialValue: settings.bodyTemplate,
            onChanged: (value) => settings.bodyTemplate = value
          )
      ),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          IconButton(onPressed: () {showHelpPage();}, icon:const Icon(Icons.help))
        ],
      ),
      body: ListView(key: UniqueKey(), children: list)
    );
  }

  copyTemplate () {
    Settings s = widget.settings;
    setState(() {
      s.bodyTemplate = s.template.bodyTemplate??'';
      s.subjectTemplate = s.template.subjectTemplate??'';
    });
  }

  showHelpPage () async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return const HelpPage();
    }));
  }
}
