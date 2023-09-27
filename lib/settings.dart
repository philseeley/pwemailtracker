import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

enum Templates {
  predictWind('Predict Wind', '{info} {lat-d.ddddd} {lon-d.ddddd} {localyyyy-MM-dd HH:mm}{tzh}{tzm}', ['tracking@predictwind.com'], ''),
  noForeignLand('No Foreign Land', 'LAT|{latd|m.mmm|c}\nLON|{lond|m.mmm|c}', ['tracking@noforeignland.com'], ''),
  noForeignLandBlog('No Foreign Land + Blog', 'LAT|{latd|m.mmm|c}\nLON|{lond|m.mmm|c}\n\nBlog here\n----', ['tracking@noforeignland.com'], ''),
  weatherRouter('Weather Router', 'Hi {info2},\n\nOn {utcyyyy-MM-dd} at {utcHH:mm} UTC, {info1} is at:\n\n{latd m.mmm c}, {lond m.mmm c}\n\nKind Regards\n{info}', null, 'Position of {info} on {info1}'),
  googleMaps('Google Maps', '{info2},\n\nhttps://www.google.com/maps/search/?api=1&query={lat-d.ddddd}%2C{lon-d.ddddd}\n\nCheers\n{info}', null, 'Position of {info} on {info1}'),
  custom('Custom', null, null, null);

  final String name;
  final String? bodyTemplate;
  final List<String>? destinationEmails;
  final String? subjectTemplate;

  const Templates(this.name, this.bodyTemplate, this.destinationEmails, this.subjectTemplate);
}

@JsonSerializable()
class Settings {
  bool firstUse;
  Templates template;
  double accuracy;
  bool autoClose;
  List<String> info;
  List<String> emailsAddresses;
  String subjectTemplate;
  String bodyTemplate;

  static File? _store;

  Settings({
    this.firstUse = true,
    this.template = Templates.predictWind,
    this.accuracy = 10.0,
    this.autoClose = false,
    this.info = const [],
    this.emailsAddresses = const [],
    this.subjectTemplate = '',
    this.bodyTemplate = ''
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
    } on Error {
      return Settings();
    }
  }

  save (){
    _store?.writeAsStringSync(json.encode(toJson()));
  }
}