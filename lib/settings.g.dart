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
      info:
          (json['info'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      emailsAddresses: (json['emailsAddresses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      subjectTemplate: json['subjectTemplate'] as String? ?? '',
      bodyTemplate: json['bodyTemplate'] as String? ?? '',
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'firstUse': instance.firstUse,
      'template': _$TemplatesEnumMap[instance.template]!,
      'accuracy': instance.accuracy,
      'autoClose': instance.autoClose,
      'info': instance.info,
      'emailsAddresses': instance.emailsAddresses,
      'subjectTemplate': instance.subjectTemplate,
      'bodyTemplate': instance.bodyTemplate,
    };

const _$TemplatesEnumMap = {
  Templates.predictWind: 'predictWind',
  Templates.noForeignLand: 'noForeignLand',
  Templates.noForeignLandBlog: 'noForeignLandBlog',
  Templates.weatherRouter: 'weatherRouter',
  Templates.custom: 'custom',
};
