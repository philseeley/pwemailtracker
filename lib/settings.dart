import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

enum Templates {
  predictWind('Predict Wind', '{user} {lat-d.ddddd} {lon-d.ddddd} {localyyyy-MM-dd HH:mm}{tz}', 'tracking@predictwind.com', ''),
  noForeignLand('No Foreign Land', 'LAT|{latd|m.mmm|c}\nLON|{lond|m.mmm|c}', 'tracking@noforeignland.com', ''),
  noForeignLandBlog('No Foreign Land + Blog', 'LAT|{latd|m.mmm|c}\nLON|{lond|m.mmm|c}\n\nBlog here\n----', 'tracking@noforeignland.com', ''),
  desCason('Des Cason', 'Hi Des,\n\nOn {utcyyyy-MM-dd} at {utcHH:mm} UTC, {pass} is at:\n\n{latd m.mmm c}, {lond m.mmm c}\n\nKind Regards\n{user}', null, 'Position of {user} on {pass}'),
  custom('Custom', '', null, null);

  final String name;
  final String template;
  final String? destinationEmail;
  final String? subject;

  const Templates(this.name, this.template, this.destinationEmail, this.subject);
}

@JsonSerializable()
class Settings {
  bool firstUse;
  Templates template;
  double accuracy;
  bool autoClose;
  String username;
  String password;
  String customDestinationEmail;
  String subject;
  String customTemplate;

  static File? _store;

  Settings({
    this.firstUse = true,
    this.template = Templates.predictWind,
    this.accuracy = 10.0,
    this.autoClose = false,
    this.username = '',
    this.password = '',
    this.customDestinationEmail = '',
    this.subject = '',
    this.customTemplate = ''
  });

  factory Settings.fromJson(Map<String, dynamic> json) =>
    _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  static load() async {
    Directory directory = await path_provider.getApplicationDocumentsDirectory();
    _store = File('${directory.path}/settings.json');

    try {
      String? s = _store?.readAsStringSync();
      dynamic data = json.decode(s ?? "");

      return Settings.fromJson(data);
    } on Exception {
      return Settings();
    }
  }

  save (){
    _store?.writeAsStringSync(json.encode(toJson()));
  }
}