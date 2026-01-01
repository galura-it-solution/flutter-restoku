// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'query_parametes.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QueryParametesModel _$QueryParametesModelFromJson(Map<String, dynamic> json) {
  return _QueryParametesModel.fromJson(json);
}

/// @nodoc
mixin _$QueryParametesModel {
  @JsonKey(name: "search")
  String get search => throw _privateConstructorUsedError;
  @JsonKey(name: "searchFields")
  List<dynamic> get searchFields => throw _privateConstructorUsedError;
  @JsonKey(name: "filters")
  List<Filter> get filters => throw _privateConstructorUsedError;
  @JsonKey(name: "orderKey")
  String get orderKey => throw _privateConstructorUsedError;
  @JsonKey(name: "orderBy")
  String get orderBy => throw _privateConstructorUsedError;
  @JsonKey(name: "fieldRange")
  String get fieldRange => throw _privateConstructorUsedError;
  @JsonKey(name: "from")
  dynamic get from => throw _privateConstructorUsedError;
  @JsonKey(name: "to")
  dynamic get to => throw _privateConstructorUsedError;
  @JsonKey(name: "page")
  int get page => throw _privateConstructorUsedError;
  @JsonKey(name: "pageSize")
  int get pageSize => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QueryParametesModelCopyWith<QueryParametesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueryParametesModelCopyWith<$Res> {
  factory $QueryParametesModelCopyWith(
          QueryParametesModel value, $Res Function(QueryParametesModel) then) =
      _$QueryParametesModelCopyWithImpl<$Res, QueryParametesModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "search") String search,
      @JsonKey(name: "searchFields") List<dynamic> searchFields,
      @JsonKey(name: "filters") List<Filter> filters,
      @JsonKey(name: "orderKey") String orderKey,
      @JsonKey(name: "orderBy") String orderBy,
      @JsonKey(name: "fieldRange") String fieldRange,
      @JsonKey(name: "from") dynamic from,
      @JsonKey(name: "to") dynamic to,
      @JsonKey(name: "page") int page,
      @JsonKey(name: "pageSize") int pageSize});
}

/// @nodoc
class _$QueryParametesModelCopyWithImpl<$Res, $Val extends QueryParametesModel>
    implements $QueryParametesModelCopyWith<$Res> {
  _$QueryParametesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? searchFields = null,
    Object? filters = null,
    Object? orderKey = null,
    Object? orderBy = null,
    Object? fieldRange = null,
    Object? from = freezed,
    Object? to = freezed,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(_value.copyWith(
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
      searchFields: null == searchFields
          ? _value.searchFields
          : searchFields // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      filters: null == filters
          ? _value.filters
          : filters // ignore: cast_nullable_to_non_nullable
              as List<Filter>,
      orderKey: null == orderKey
          ? _value.orderKey
          : orderKey // ignore: cast_nullable_to_non_nullable
              as String,
      orderBy: null == orderBy
          ? _value.orderBy
          : orderBy // ignore: cast_nullable_to_non_nullable
              as String,
      fieldRange: null == fieldRange
          ? _value.fieldRange
          : fieldRange // ignore: cast_nullable_to_non_nullable
              as String,
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as dynamic,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as dynamic,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QueryParametesModelImplCopyWith<$Res>
    implements $QueryParametesModelCopyWith<$Res> {
  factory _$$QueryParametesModelImplCopyWith(_$QueryParametesModelImpl value,
          $Res Function(_$QueryParametesModelImpl) then) =
      __$$QueryParametesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "search") String search,
      @JsonKey(name: "searchFields") List<dynamic> searchFields,
      @JsonKey(name: "filters") List<Filter> filters,
      @JsonKey(name: "orderKey") String orderKey,
      @JsonKey(name: "orderBy") String orderBy,
      @JsonKey(name: "fieldRange") String fieldRange,
      @JsonKey(name: "from") dynamic from,
      @JsonKey(name: "to") dynamic to,
      @JsonKey(name: "page") int page,
      @JsonKey(name: "pageSize") int pageSize});
}

/// @nodoc
class __$$QueryParametesModelImplCopyWithImpl<$Res>
    extends _$QueryParametesModelCopyWithImpl<$Res, _$QueryParametesModelImpl>
    implements _$$QueryParametesModelImplCopyWith<$Res> {
  __$$QueryParametesModelImplCopyWithImpl(_$QueryParametesModelImpl _value,
      $Res Function(_$QueryParametesModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? search = null,
    Object? searchFields = null,
    Object? filters = null,
    Object? orderKey = null,
    Object? orderBy = null,
    Object? fieldRange = null,
    Object? from = freezed,
    Object? to = freezed,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(_$QueryParametesModelImpl(
      search: null == search
          ? _value.search
          : search // ignore: cast_nullable_to_non_nullable
              as String,
      searchFields: null == searchFields
          ? _value._searchFields
          : searchFields // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      filters: null == filters
          ? _value._filters
          : filters // ignore: cast_nullable_to_non_nullable
              as List<Filter>,
      orderKey: null == orderKey
          ? _value.orderKey
          : orderKey // ignore: cast_nullable_to_non_nullable
              as String,
      orderBy: null == orderBy
          ? _value.orderBy
          : orderBy // ignore: cast_nullable_to_non_nullable
              as String,
      fieldRange: null == fieldRange
          ? _value.fieldRange
          : fieldRange // ignore: cast_nullable_to_non_nullable
              as String,
      from: freezed == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as dynamic,
      to: freezed == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as dynamic,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QueryParametesModelImpl implements _QueryParametesModel {
  const _$QueryParametesModelImpl(
      {@JsonKey(name: "search") required this.search,
      @JsonKey(name: "searchFields") required final List<dynamic> searchFields,
      @JsonKey(name: "filters") required final List<Filter> filters,
      @JsonKey(name: "orderKey") required this.orderKey,
      @JsonKey(name: "orderBy") required this.orderBy,
      @JsonKey(name: "fieldRange") required this.fieldRange,
      @JsonKey(name: "from") required this.from,
      @JsonKey(name: "to") required this.to,
      @JsonKey(name: "page") required this.page,
      @JsonKey(name: "pageSize") required this.pageSize})
      : _searchFields = searchFields,
        _filters = filters;

  factory _$QueryParametesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QueryParametesModelImplFromJson(json);

  @override
  @JsonKey(name: "search")
  final String search;
  final List<dynamic> _searchFields;
  @override
  @JsonKey(name: "searchFields")
  List<dynamic> get searchFields {
    if (_searchFields is EqualUnmodifiableListView) return _searchFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchFields);
  }

  final List<Filter> _filters;
  @override
  @JsonKey(name: "filters")
  List<Filter> get filters {
    if (_filters is EqualUnmodifiableListView) return _filters;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filters);
  }

  @override
  @JsonKey(name: "orderKey")
  final String orderKey;
  @override
  @JsonKey(name: "orderBy")
  final String orderBy;
  @override
  @JsonKey(name: "fieldRange")
  final String fieldRange;
  @override
  @JsonKey(name: "from")
  final dynamic from;
  @override
  @JsonKey(name: "to")
  final dynamic to;
  @override
  @JsonKey(name: "page")
  final int page;
  @override
  @JsonKey(name: "pageSize")
  final int pageSize;

  @override
  String toString() {
    return 'QueryParametesModel(search: $search, searchFields: $searchFields, filters: $filters, orderKey: $orderKey, orderBy: $orderBy, fieldRange: $fieldRange, from: $from, to: $to, page: $page, pageSize: $pageSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueryParametesModelImpl &&
            (identical(other.search, search) || other.search == search) &&
            const DeepCollectionEquality()
                .equals(other._searchFields, _searchFields) &&
            const DeepCollectionEquality().equals(other._filters, _filters) &&
            (identical(other.orderKey, orderKey) ||
                other.orderKey == orderKey) &&
            (identical(other.orderBy, orderBy) || other.orderBy == orderBy) &&
            (identical(other.fieldRange, fieldRange) ||
                other.fieldRange == fieldRange) &&
            const DeepCollectionEquality().equals(other.from, from) &&
            const DeepCollectionEquality().equals(other.to, to) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      search,
      const DeepCollectionEquality().hash(_searchFields),
      const DeepCollectionEquality().hash(_filters),
      orderKey,
      orderBy,
      fieldRange,
      const DeepCollectionEquality().hash(from),
      const DeepCollectionEquality().hash(to),
      page,
      pageSize);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QueryParametesModelImplCopyWith<_$QueryParametesModelImpl> get copyWith =>
      __$$QueryParametesModelImplCopyWithImpl<_$QueryParametesModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueryParametesModelImplToJson(
      this,
    );
  }
}

abstract class _QueryParametesModel implements QueryParametesModel {
  const factory _QueryParametesModel(
      {@JsonKey(name: "search") required final String search,
      @JsonKey(name: "searchFields") required final List<dynamic> searchFields,
      @JsonKey(name: "filters") required final List<Filter> filters,
      @JsonKey(name: "orderKey") required final String orderKey,
      @JsonKey(name: "orderBy") required final String orderBy,
      @JsonKey(name: "fieldRange") required final String fieldRange,
      @JsonKey(name: "from") required final dynamic from,
      @JsonKey(name: "to") required final dynamic to,
      @JsonKey(name: "page") required final int page,
      @JsonKey(name: "pageSize")
      required final int pageSize}) = _$QueryParametesModelImpl;

  factory _QueryParametesModel.fromJson(Map<String, dynamic> json) =
      _$QueryParametesModelImpl.fromJson;

  @override
  @JsonKey(name: "search")
  String get search;
  @override
  @JsonKey(name: "searchFields")
  List<dynamic> get searchFields;
  @override
  @JsonKey(name: "filters")
  List<Filter> get filters;
  @override
  @JsonKey(name: "orderKey")
  String get orderKey;
  @override
  @JsonKey(name: "orderBy")
  String get orderBy;
  @override
  @JsonKey(name: "fieldRange")
  String get fieldRange;
  @override
  @JsonKey(name: "from")
  dynamic get from;
  @override
  @JsonKey(name: "to")
  dynamic get to;
  @override
  @JsonKey(name: "page")
  int get page;
  @override
  @JsonKey(name: "pageSize")
  int get pageSize;
  @override
  @JsonKey(ignore: true)
  _$$QueryParametesModelImplCopyWith<_$QueryParametesModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Filter _$FilterFromJson(Map<String, dynamic> json) {
  return _Filter.fromJson(json);
}

/// @nodoc
mixin _$Filter {
  @JsonKey(name: "column")
  String get column => throw _privateConstructorUsedError;
  @JsonKey(name: "values")
  List<dynamic> get values => throw _privateConstructorUsedError;
  @JsonKey(name: "equal")
  bool get equal => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FilterCopyWith<Filter> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FilterCopyWith<$Res> {
  factory $FilterCopyWith(Filter value, $Res Function(Filter) then) =
      _$FilterCopyWithImpl<$Res, Filter>;
  @useResult
  $Res call(
      {@JsonKey(name: "column") String column,
      @JsonKey(name: "values") List<dynamic> values,
      @JsonKey(name: "equal") bool equal});
}

/// @nodoc
class _$FilterCopyWithImpl<$Res, $Val extends Filter>
    implements $FilterCopyWith<$Res> {
  _$FilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? column = null,
    Object? values = null,
    Object? equal = null,
  }) {
    return _then(_value.copyWith(
      column: null == column
          ? _value.column
          : column // ignore: cast_nullable_to_non_nullable
              as String,
      values: null == values
          ? _value.values
          : values // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      equal: null == equal
          ? _value.equal
          : equal // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FilterImplCopyWith<$Res> implements $FilterCopyWith<$Res> {
  factory _$$FilterImplCopyWith(
          _$FilterImpl value, $Res Function(_$FilterImpl) then) =
      __$$FilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "column") String column,
      @JsonKey(name: "values") List<dynamic> values,
      @JsonKey(name: "equal") bool equal});
}

/// @nodoc
class __$$FilterImplCopyWithImpl<$Res>
    extends _$FilterCopyWithImpl<$Res, _$FilterImpl>
    implements _$$FilterImplCopyWith<$Res> {
  __$$FilterImplCopyWithImpl(
      _$FilterImpl _value, $Res Function(_$FilterImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? column = null,
    Object? values = null,
    Object? equal = null,
  }) {
    return _then(_$FilterImpl(
      column: null == column
          ? _value.column
          : column // ignore: cast_nullable_to_non_nullable
              as String,
      values: null == values
          ? _value._values
          : values // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      equal: null == equal
          ? _value.equal
          : equal // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FilterImpl implements _Filter {
  const _$FilterImpl(
      {@JsonKey(name: "column") required this.column,
      @JsonKey(name: "values") required final List<dynamic> values,
      @JsonKey(name: "equal") required this.equal})
      : _values = values;

  factory _$FilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$FilterImplFromJson(json);

  @override
  @JsonKey(name: "column")
  final String column;
  final List<dynamic> _values;
  @override
  @JsonKey(name: "values")
  List<dynamic> get values {
    if (_values is EqualUnmodifiableListView) return _values;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_values);
  }

  @override
  @JsonKey(name: "equal")
  final bool equal;

  @override
  String toString() {
    return 'Filter(column: $column, values: $values, equal: $equal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterImpl &&
            (identical(other.column, column) || other.column == column) &&
            const DeepCollectionEquality().equals(other._values, _values) &&
            (identical(other.equal, equal) || other.equal == equal));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, column, const DeepCollectionEquality().hash(_values), equal);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterImplCopyWith<_$FilterImpl> get copyWith =>
      __$$FilterImplCopyWithImpl<_$FilterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FilterImplToJson(
      this,
    );
  }
}

abstract class _Filter implements Filter {
  const factory _Filter(
      {@JsonKey(name: "column") required final String column,
      @JsonKey(name: "values") required final List<dynamic> values,
      @JsonKey(name: "equal") required final bool equal}) = _$FilterImpl;

  factory _Filter.fromJson(Map<String, dynamic> json) = _$FilterImpl.fromJson;

  @override
  @JsonKey(name: "column")
  String get column;
  @override
  @JsonKey(name: "values")
  List<dynamic> get values;
  @override
  @JsonKey(name: "equal")
  bool get equal;
  @override
  @JsonKey(ignore: true)
  _$$FilterImplCopyWith<_$FilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
