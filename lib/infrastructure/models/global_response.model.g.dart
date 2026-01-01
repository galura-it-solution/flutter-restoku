// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_response.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GlobalResponseModelImpl _$$GlobalResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$GlobalResponseModelImpl(
      code: (json['status'] as num).toInt(),
      message: json['message'] as String,
      data: json['data'],
    );

Map<String, dynamic> _$$GlobalResponseModelImplToJson(
        _$GlobalResponseModelImpl instance) =>
    <String, dynamic>{
      'status': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
