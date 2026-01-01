// To parse this JSON data, do
//
//     final optionsModel = optionsModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'options.model.freezed.dart';
part 'options.model.g.dart';

List<OptionsModel> optionsModelFromJson(String str) => List<OptionsModel>.from(
    json.decode(str).map((x) => OptionsModel.fromJson(x)));

String optionsModelToJson(List<OptionsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

@freezed
abstract class OptionsModel with _$OptionsModel {
  const factory OptionsModel({
    @JsonKey(name: "label") required String label,
    @JsonKey(name: "value") required dynamic value,
  }) = _OptionsModel;

  factory OptionsModel.fromJson(Map<String, dynamic> json) =>
      _$OptionsModelFromJson(json);
}
