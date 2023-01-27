// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      email: json['email'] as String?,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 10.0,
      autoClose: json['autoClose'] as bool? ?? true,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'email': instance.email,
      'accuracy': instance.accuracy,
      'autoClose': instance.autoClose,
    };
