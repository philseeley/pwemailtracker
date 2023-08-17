import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

enum Templates {
  predictWind('Predict Wind', '{ident} {lat-d.ddddd} {lon-d.ddddd} {localyyyy-MM-dd HH:mm}{tz}', ['tracking@predictwind.com'], ''),
  noForeignLand('No Foreign Land', 'LAT|{latd|m.mmm|c}\nLON|{lond|m.mmm|c}', ['tracking@noforeignland.com'], ''),
  noForeignLandBlog('No Foreign Land + Blog', 'LAT|{latd|m.mmm|c}\nLON|{lond|m.mmm|c}\n\nBlog here\n----', ['tracking@noforeignland.com'], ''),
  weatherRouter('Weather Router', 'Hi {ident2},\n\nOn {utcyyyy-MM-dd} at {utcHH:mm} UTC, {ident1} is at:\n\n{latd m.mmm c}, {lond m.mmm c}\n\nKind Regards\n{ident}', null, 'Position of {ident} on {ident1}'),
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
  List<String> ident;
  List<String> destinationEmails;
  String subjectTemplate;
  String bodyTemplate;

  static File? _store;

  Settings({
    this.firstUse = true,
    this.template = Templates.predictWind,
    this.accuracy = 10.0,
    this.autoClose = false,
    this.ident = const [],
    this.destinationEmails = const [],
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
    } on Error {
      return Settings();
    }
  }

  save (){
    _store?.writeAsStringSync(json.encode(toJson()));
  }
}