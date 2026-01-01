// To parse this JSON data, do
//
//     final queryParametesModel = queryParametesModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'query_parametes.model.freezed.dart';
part 'query_parametes.model.g.dart';

QueryParametesModel queryParametesModelFromJson(String str) =>
    QueryParametesModel.fromJson(json.decode(str));

String queryParametesModelToJson(QueryParametesModel data) =>
    json.encode(data.toJson());

@freezed
abstract class QueryParametesModel with _$QueryParametesModel {
  const factory QueryParametesModel({
    @JsonKey(name: "search") required String search,
    @JsonKey(name: "searchFields") required List<dynamic> searchFields,
    @JsonKey(name: "filters") required List<Filter> filters,
    @JsonKey(name: "orderKey") required String orderKey,
    @JsonKey(name: "orderBy") required String orderBy,
    @JsonKey(name: "fieldRange") required String fieldRange,
    @JsonKey(name: "from") required dynamic from,
    @JsonKey(name: "to") required dynamic to,
    @JsonKey(name: "page") required int page,
    @JsonKey(name: "pageSize") required int pageSize,
  }) = _QueryParametesModel;

  factory QueryParametesModel.fromJson(Map<String, dynamic> json) =>
      _$QueryParametesModelFromJson(json);
}

@freezed
abstract class Filter with _$Filter {
  const factory Filter({
    @JsonKey(name: "column") required String column,
    @JsonKey(name: "values") required List<dynamic> values,
    @JsonKey(name: "equal") required bool equal,
  }) = _Filter;

  factory Filter.fromJson(Map<String, dynamic> json) => _$FilterFromJson(json);
}
