// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_parametes.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QueryParametesModelImpl _$$QueryParametesModelImplFromJson(
        Map<String, dynamic> json) =>
    _$QueryParametesModelImpl(
      search: json['search'] as String,
      searchFields: json['searchFields'] as List<dynamic>,
      filters: (json['filters'] as List<dynamic>)
          .map((e) => Filter.fromJson(e as Map<String, dynamic>))
          .toList(),
      orderKey: json['orderKey'] as String,
      orderBy: json['orderBy'] as String,
      fieldRange: json['fieldRange'] as String,
      from: json['from'],
      to: json['to'],
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
    );

Map<String, dynamic> _$$QueryParametesModelImplToJson(
        _$QueryParametesModelImpl instance) =>
    <String, dynamic>{
      'search': instance.search,
      'searchFields': instance.searchFields,
      'filters': instance.filters,
      'orderKey': instance.orderKey,
      'orderBy': instance.orderBy,
      'fieldRange': instance.fieldRange,
      'from': instance.from,
      'to': instance.to,
      'page': instance.page,
      'pageSize': instance.pageSize,
    };

_$FilterImpl _$$FilterImplFromJson(Map<String, dynamic> json) => _$FilterImpl(
      column: json['column'] as String,
      values: json['values'] as List<dynamic>,
      equal: json['equal'] as bool,
    );

Map<String, dynamic> _$$FilterImplToJson(_$FilterImpl instance) =>
    <String, dynamic>{
      'column': instance.column,
      'values': instance.values,
      'equal': instance.equal,
    };
