// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      firstUse: json['firstUse'] as bool? ?? true,
      template: $enumDecodeNullable(_$TemplatesEnumMap, json['template']) ??
          Templates.predictWind,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 10.0,
      autoClose: json['autoClose'] as bool? ?? false,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      customDestinationEmail: json['customDestinationEmail'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      customTemplate: json['customTemplate'] as String? ?? '',
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'firstUse': instance.firstUse,
      'template': _$TemplatesEnumMap[instance.template]!,
      'accuracy': instance.accuracy,
      'autoClose': instance.autoClose,
      'username': instance.username,
      'password': instance.password,
      'customDestinationEmail': instance.customDestinationEmail,
      'subject': instance.subject,
      'customTemplate': instance.customTemplate,
    };

const _$TemplatesEnumMap = {
  Templates.predictWind: 'predictWind',
  Templates.noForeignLand: 'noForeignLand',
  Templates.noForeignLandBlog: 'noForeignLandBlog',
  Templates.desCason: 'desCason',
  Templates.custom: 'custom',
};
