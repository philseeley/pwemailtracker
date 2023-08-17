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
      ident:
          (json['ident'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      customDestinationEmail: json['customDestinationEmail'] as String? ?? '',
      subjectTemplate: json['subject'] as String? ?? '',
      bodyTemplate: json['customTemplate'] as String? ?? '',
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'firstUse': instance.firstUse,
      'template': _$TemplatesEnumMap[instance.template]!,
      'accuracy': instance.accuracy,
      'autoClose': instance.autoClose,
      'ident': instance.ident,
      'customDestinationEmail': instance.customDestinationEmail,
      'subject': instance.subjectTemplate,
      'customTemplate': instance.bodyTemplate,
    };

const _$TemplatesEnumMap = {
  Templates.predictWind: 'predictWind',
  Templates.noForeignLand: 'noForeignLand',
  Templates.noForeignLandBlog: 'noForeignLandBlog',
  Templates.desCason: 'desCason',
  Templates.custom: 'custom',
};
