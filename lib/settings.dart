import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

enum CoordFormat {
  decimalDegrees('Decimal Degrees'),
  decimalMinutes('Decimal Minutes'),
  degreesMinutesSeconds('Degrees Minutes Seconds');

  final String name;

  const CoordFormat(this.name);
}

@JsonSerializable()
class Settings {
  bool firstUse;
  String? ident;
  String destinationEmail;
  CoordFormat coordFormat;
  bool cardinalFormat;
  double accuracy;
  bool autoClose;
  bool includeDateTime;

  static File? _store;

  Settings({
    this.firstUse = true,
    this.ident,
    this.destinationEmail = 'tracking@predictwind.com',
    this.coordFormat = CoordFormat.decimalDegrees,
    this.cardinalFormat = false,
    this.accuracy = 10.0,
    this.autoClose = false,
    this.includeDateTime = true});

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