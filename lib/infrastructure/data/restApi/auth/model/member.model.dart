import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.model.freezed.dart';
part 'member.model.g.dart';

// Helper untuk encode/decode cepat
MemberModel memberModelFromJson(String str) =>
    MemberModel.fromJson(json.decode(str));

String memberModelToJson(MemberModel data) =>
    json.encode(data.toJson());

@freezed
class MemberModel with _$MemberModel {
  const factory MemberModel({
    required String image,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'member_name') required String memberName,
    @JsonKey(name: 'member_email') required String memberEmail,
    @JsonKey(name: 'member_type') required String memberType,
    @JsonKey(name: 'member_type_id') required String memberTypeId,
    @JsonKey(name: 'register_date') required DateTime registerDate,
    @JsonKey(name: 'expire_date') required DateTime expireDate,
    @JsonKey(name: 'inst_name') required String instName,
  }) = _MemberModel;

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);
}
