// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_response.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GlobalResponseModel _$GlobalResponseModelFromJson(Map<String, dynamic> json) {
  return _GlobalResponseModel.fromJson(json);
}

/// @nodoc
mixin _$GlobalResponseModel {
  @JsonKey(name: "status")
  int get code => throw _privateConstructorUsedError;
  @JsonKey(name: "message")
  String get message => throw _privateConstructorUsedError;
  @JsonKey(name: "data")
  dynamic get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GlobalResponseModelCopyWith<GlobalResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalResponseModelCopyWith<$Res> {
  factory $GlobalResponseModelCopyWith(
          GlobalResponseModel value, $Res Function(GlobalResponseModel) then) =
      _$GlobalResponseModelCopyWithImpl<$Res, GlobalResponseModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "status") int code,
      @JsonKey(name: "message") String message,
      @JsonKey(name: "data") dynamic data});
}

/// @nodoc
class _$GlobalResponseModelCopyWithImpl<$Res, $Val extends GlobalResponseModel>
    implements $GlobalResponseModelCopyWith<$Res> {
  _$GlobalResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GlobalResponseModelImplCopyWith<$Res>
    implements $GlobalResponseModelCopyWith<$Res> {
  factory _$$GlobalResponseModelImplCopyWith(_$GlobalResponseModelImpl value,
          $Res Function(_$GlobalResponseModelImpl) then) =
      __$$GlobalResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "status") int code,
      @JsonKey(name: "message") String message,
      @JsonKey(name: "data") dynamic data});
}

/// @nodoc
class __$$GlobalResponseModelImplCopyWithImpl<$Res>
    extends _$GlobalResponseModelCopyWithImpl<$Res, _$GlobalResponseModelImpl>
    implements _$$GlobalResponseModelImplCopyWith<$Res> {
  __$$GlobalResponseModelImplCopyWithImpl(_$GlobalResponseModelImpl _value,
      $Res Function(_$GlobalResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? message = null,
    Object? data = freezed,
  }) {
    return _then(_$GlobalResponseModelImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GlobalResponseModelImpl extends _GlobalResponseModel {
  const _$GlobalResponseModelImpl(
      {@JsonKey(name: "status") required this.code,
      @JsonKey(name: "message") required this.message,
      @JsonKey(name: "data") required this.data})
      : super._();

  factory _$GlobalResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GlobalResponseModelImplFromJson(json);

  @override
  @JsonKey(name: "status")
  final int code;
  @override
  @JsonKey(name: "message")
  final String message;
  @override
  @JsonKey(name: "data")
  final dynamic data;

  @override
  String toString() {
    return 'GlobalResponseModel(code: $code, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalResponseModelImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, code, message, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalResponseModelImplCopyWith<_$GlobalResponseModelImpl> get copyWith =>
      __$$GlobalResponseModelImplCopyWithImpl<_$GlobalResponseModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GlobalResponseModelImplToJson(
      this,
    );
  }
}

abstract class _GlobalResponseModel extends GlobalResponseModel {
  const factory _GlobalResponseModel(
          {@JsonKey(name: "status") required final int code,
          @JsonKey(name: "message") required final String message,
          @JsonKey(name: "data") required final dynamic data}) =
      _$GlobalResponseModelImpl;
  const _GlobalResponseModel._() : super._();

  factory _GlobalResponseModel.fromJson(Map<String, dynamic> json) =
      _$GlobalResponseModelImpl.fromJson;

  @override
  @JsonKey(name: "status")
  int get code;
  @override
  @JsonKey(name: "message")
  String get message;
  @override
  @JsonKey(name: "data")
  dynamic get data;
  @override
  @JsonKey(ignore: true)
  _$$GlobalResponseModelImplCopyWith<_$GlobalResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
