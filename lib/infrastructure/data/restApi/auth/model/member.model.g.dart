// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberModelImpl _$$MemberModelImplFromJson(Map<String, dynamic> json) =>
    _$MemberModelImpl(
      image: json['image'] as String,
      memberId: json['member_id'] as String,
      memberName: json['member_name'] as String,
      memberEmail: json['member_email'] as String,
      memberType: json['member_type'] as String,
      memberTypeId: json['member_type_id'] as String,
      registerDate: DateTime.parse(json['register_date'] as String),
      expireDate: DateTime.parse(json['expire_date'] as String),
      instName: json['inst_name'] as String,
    );

Map<String, dynamic> _$$MemberModelImplToJson(_$MemberModelImpl instance) =>
    <String, dynamic>{
      'image': instance.image,
      'member_id': instance.memberId,
      'member_name': instance.memberName,
      'member_email': instance.memberEmail,
      'member_type': instance.memberType,
      'member_type_id': instance.memberTypeId,
      'register_date': instance.registerDate.toIso8601String(),
      'expire_date': instance.expireDate.toIso8601String(),
      'inst_name': instance.instName,
    };
