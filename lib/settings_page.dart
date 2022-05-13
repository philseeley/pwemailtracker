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

    List<Widget> list = [
      ListTile(
        leading: const Text("Email"),
        title: TextFormField(
          initialValue: settings.email,
          onChanged: (value) => settings.email = value.isNotEmpty ? value.trim() : null
        )
      ),
      ListTile(
        leading: const Text("Accuracy"),
        title: Slider(
          min: 10.0,
          max: 100.0,
          divisions: 6,
          value: settings.accuracy,
          label: "${settings.accuracy}",
          onChanged: (double value) {
            setState(() {
              settings.accuracy = value;
            });
          }),
      )
    ];

    return(Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(children: list)
    ));
  }
}
