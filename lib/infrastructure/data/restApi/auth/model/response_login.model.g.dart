// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_login.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResponseLoginModelImpl _$$ResponseLoginModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ResponseLoginModelImpl(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ResponseLoginModelImplToJson(
        _$ResponseLoginModelImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
      token: json['token'] as String,
      memberId: json['member_id'] as String,
      memberName: json['member_name'] as String,
      memberEmail: json['member_email'] as String,
      memberType: json['member_type'] as String,
      registerDate: DateTime.parse(json['register_date'] as String),
      expireDate: DateTime.parse(json['expire_date'] as String),
      instName: json['inst_name'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'member_id': instance.memberId,
      'member_name': instance.memberName,
      'member_email': instance.memberEmail,
      'member_type': instance.memberType,
      'register_date': instance.registerDate.toIso8601String(),
      'expire_date': instance.expireDate.toIso8601String(),
      'inst_name': instance.instName,
      'image': instance.image,
    };
