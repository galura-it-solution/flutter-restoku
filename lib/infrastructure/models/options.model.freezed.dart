// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'options.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OptionsModel _$OptionsModelFromJson(Map<String, dynamic> json) {
  return _OptionsModel.fromJson(json);
}

/// @nodoc
mixin _$OptionsModel {
  @JsonKey(name: "label")
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: "value")
  dynamic get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OptionsModelCopyWith<OptionsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OptionsModelCopyWith<$Res> {
  factory $OptionsModelCopyWith(
          OptionsModel value, $Res Function(OptionsModel) then) =
      _$OptionsModelCopyWithImpl<$Res, OptionsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: "label") String label,
      @JsonKey(name: "value") dynamic value});
}

/// @nodoc
class _$OptionsModelCopyWithImpl<$Res, $Val extends OptionsModel>
    implements $OptionsModelCopyWith<$Res> {
  _$OptionsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = freezed,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OptionsModelImplCopyWith<$Res>
    implements $OptionsModelCopyWith<$Res> {
  factory _$$OptionsModelImplCopyWith(
          _$OptionsModelImpl value, $Res Function(_$OptionsModelImpl) then) =
      __$$OptionsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "label") String label,
      @JsonKey(name: "value") dynamic value});
}

/// @nodoc
class __$$OptionsModelImplCopyWithImpl<$Res>
    extends _$OptionsModelCopyWithImpl<$Res, _$OptionsModelImpl>
    implements _$$OptionsModelImplCopyWith<$Res> {
  __$$OptionsModelImplCopyWithImpl(
      _$OptionsModelImpl _value, $Res Function(_$OptionsModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = freezed,
  }) {
    return _then(_$OptionsModelImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OptionsModelImpl implements _OptionsModel {
  const _$OptionsModelImpl(
      {@JsonKey(name: "label") required this.label,
      @JsonKey(name: "value") required this.value});

  factory _$OptionsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OptionsModelImplFromJson(json);

  @override
  @JsonKey(name: "label")
  final String label;
  @override
  @JsonKey(name: "value")
  final dynamic value;

  @override
  String toString() {
    return 'OptionsModel(label: $label, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OptionsModelImpl &&
            (identical(other.label, label) || other.label == label) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, label, const DeepCollectionEquality().hash(value));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OptionsModelImplCopyWith<_$OptionsModelImpl> get copyWith =>
      __$$OptionsModelImplCopyWithImpl<_$OptionsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OptionsModelImplToJson(
      this,
    );
  }
}

abstract class _OptionsModel implements OptionsModel {
  const factory _OptionsModel(
          {@JsonKey(name: "label") required final String label,
          @JsonKey(name: "value") required final dynamic value}) =
      _$OptionsModelImpl;

  factory _OptionsModel.fromJson(Map<String, dynamic> json) =
      _$OptionsModelImpl.fromJson;

  @override
  @JsonKey(name: "label")
  String get label;
  @override
  @JsonKey(name: "value")
  dynamic get value;
  @override
  @JsonKey(ignore: true)
  _$$OptionsModelImplCopyWith<_$OptionsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
