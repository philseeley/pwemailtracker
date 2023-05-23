// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      firstUse: json['firstUse'] as bool? ?? true,
      ident: json['ident'] as String?,
      destinationEmail:
          json['destinationEmail'] as String? ?? 'tracking@predictwind.com',
      coordFormat:
          $enumDecodeNullable(_$CoordFormatEnumMap, json['coordFormat']) ??
              CoordFormat.decimalDegrees,
      cardinalFormat: json['cardinalFormat'] as bool? ?? false,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 10.0,
      autoClose: json['autoClose'] as bool? ?? false,
      includeDateTime: json['includeDateTime'] as bool? ?? true,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'firstUse': instance.firstUse,
      'ident': instance.ident,
      'destinationEmail': instance.destinationEmail,
      'coordFormat': _$CoordFormatEnumMap[instance.coordFormat]!,
      'cardinalFormat': instance.cardinalFormat,
      'accuracy': instance.accuracy,
      'autoClose': instance.autoClose,
      'includeDateTime': instance.includeDateTime,
    };

const _$CoordFormatEnumMap = {
  CoordFormat.decimalDegrees: 'decimalDegrees',
  CoordFormat.decimalMinutes: 'decimalMinutes',
  CoordFormat.degreesMinutesSeconds: 'degreesMinutesSeconds',
};
