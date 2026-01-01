// To parse this JSON data, do
//
//     final globalResponseModel = globalResponseModelFromMap(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'global_response.model.freezed.dart';
part 'global_response.model.g.dart';

GlobalResponseModel globalResponseModelFromJson(String str) =>
    GlobalResponseModel.fromJson(json.decode(str));

String globalResponseModelToJson(GlobalResponseModel data) =>
    json.encode(data.toJson());

@freezed
abstract class GlobalResponseModel with _$GlobalResponseModel {
  const GlobalResponseModel._();

  const factory GlobalResponseModel({
    @JsonKey(name: "status") required int code,
    @JsonKey(name: "message") required String message,
    @JsonKey(name: "data") required dynamic data,
  }) = _GlobalResponseModel;

  factory GlobalResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GlobalResponseModelFromJson(json);
  
  bool get success => code >= 200 && code < 300;
  bool get redirected => code >= 300 && code < 400;
  bool get clientError => code >= 400 && code < 500;
  bool get serverError => code >= 500;
  String get description => "$message (Kode $code).\n\nData: $data";
}
