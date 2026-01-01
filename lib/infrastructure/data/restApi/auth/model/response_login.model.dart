// To parse this JSON data, do
//
//     final responseLoginModel = responseLoginModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'response_login.model.freezed.dart';
part 'response_login.model.g.dart';

ResponseLoginModel responseLoginModelFromJson(String str) =>
    ResponseLoginModel.fromJson(json.decode(str));

String responseLoginModelToJson(ResponseLoginModel data) =>
    json.encode(data.toJson());

@freezed
abstract class ResponseLoginModel with _$ResponseLoginModel {
  const factory ResponseLoginModel({
    required bool status,
    required String message,
    required Data data,
  }) = _ResponseLoginModel;

  factory ResponseLoginModel.fromJson(Map<String, dynamic> json) =>
      _$ResponseLoginModelFromJson(json);
}

@freezed
abstract class Data with _$Data {
  const factory Data({
    required String token,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'member_name') required String memberName,
    @JsonKey(name: 'member_email') required String memberEmail,
    @JsonKey(name: 'member_type') required String memberType,
    @JsonKey(name: 'register_date') required DateTime registerDate,
    @JsonKey(name: 'expire_date') required DateTime expireDate,
    @JsonKey(name: 'inst_name') required String instName,
    required String image,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
