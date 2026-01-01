// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'response_login.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ResponseLoginModel _$ResponseLoginModelFromJson(Map<String, dynamic> json) {
  return _ResponseLoginModel.fromJson(json);
}

/// @nodoc
mixin _$ResponseLoginModel {
  bool get status => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  Data get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ResponseLoginModelCopyWith<ResponseLoginModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResponseLoginModelCopyWith<$Res> {
  factory $ResponseLoginModelCopyWith(
          ResponseLoginModel value, $Res Function(ResponseLoginModel) then) =
      _$ResponseLoginModelCopyWithImpl<$Res, ResponseLoginModel>;
  @useResult
  $Res call({bool status, String message, Data data});

  $DataCopyWith<$Res> get data;
}

/// @nodoc
class _$ResponseLoginModelCopyWithImpl<$Res, $Val extends ResponseLoginModel>
    implements $ResponseLoginModelCopyWith<$Res> {
  _$ResponseLoginModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Data,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $DataCopyWith<$Res> get data {
    return $DataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ResponseLoginModelImplCopyWith<$Res>
    implements $ResponseLoginModelCopyWith<$Res> {
  factory _$$ResponseLoginModelImplCopyWith(_$ResponseLoginModelImpl value,
          $Res Function(_$ResponseLoginModelImpl) then) =
      __$$ResponseLoginModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool status, String message, Data data});

  @override
  $DataCopyWith<$Res> get data;
}

/// @nodoc
class __$$ResponseLoginModelImplCopyWithImpl<$Res>
    extends _$ResponseLoginModelCopyWithImpl<$Res, _$ResponseLoginModelImpl>
    implements _$$ResponseLoginModelImplCopyWith<$Res> {
  __$$ResponseLoginModelImplCopyWithImpl(_$ResponseLoginModelImpl _value,
      $Res Function(_$ResponseLoginModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? message = null,
    Object? data = null,
  }) {
    return _then(_$ResponseLoginModelImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Data,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResponseLoginModelImpl implements _ResponseLoginModel {
  const _$ResponseLoginModelImpl(
      {required this.status, required this.message, required this.data});

  factory _$ResponseLoginModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResponseLoginModelImplFromJson(json);

  @override
  final bool status;
  @override
  final String message;
  @override
  final Data data;

  @override
  String toString() {
    return 'ResponseLoginModel(status: $status, message: $message, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResponseLoginModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, status, message, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ResponseLoginModelImplCopyWith<_$ResponseLoginModelImpl> get copyWith =>
      __$$ResponseLoginModelImplCopyWithImpl<_$ResponseLoginModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResponseLoginModelImplToJson(
      this,
    );
  }
}

abstract class _ResponseLoginModel implements ResponseLoginModel {
  const factory _ResponseLoginModel(
      {required final bool status,
      required final String message,
      required final Data data}) = _$ResponseLoginModelImpl;

  factory _ResponseLoginModel.fromJson(Map<String, dynamic> json) =
      _$ResponseLoginModelImpl.fromJson;

  @override
  bool get status;
  @override
  String get message;
  @override
  Data get data;
  @override
  @JsonKey(ignore: true)
  _$$ResponseLoginModelImplCopyWith<_$ResponseLoginModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Data _$DataFromJson(Map<String, dynamic> json) {
  return _Data.fromJson(json);
}

/// @nodoc
mixin _$Data {
  String get token => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  String get memberId => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_name')
  String get memberName => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_email')
  String get memberEmail => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_type')
  String get memberType => throw _privateConstructorUsedError;
  @JsonKey(name: 'register_date')
  DateTime get registerDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'expire_date')
  DateTime get expireDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'inst_name')
  String get instName => throw _privateConstructorUsedError;
  String get image => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DataCopyWith<Data> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataCopyWith<$Res> {
  factory $DataCopyWith(Data value, $Res Function(Data) then) =
      _$DataCopyWithImpl<$Res, Data>;
  @useResult
  $Res call(
      {String token,
      @JsonKey(name: 'member_id') String memberId,
      @JsonKey(name: 'member_name') String memberName,
      @JsonKey(name: 'member_email') String memberEmail,
      @JsonKey(name: 'member_type') String memberType,
      @JsonKey(name: 'register_date') DateTime registerDate,
      @JsonKey(name: 'expire_date') DateTime expireDate,
      @JsonKey(name: 'inst_name') String instName,
      String image});
}

/// @nodoc
class _$DataCopyWithImpl<$Res, $Val extends Data>
    implements $DataCopyWith<$Res> {
  _$DataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? memberId = null,
    Object? memberName = null,
    Object? memberEmail = null,
    Object? memberType = null,
    Object? registerDate = null,
    Object? expireDate = null,
    Object? instName = null,
    Object? image = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      memberName: null == memberName
          ? _value.memberName
          : memberName // ignore: cast_nullable_to_non_nullable
              as String,
      memberEmail: null == memberEmail
          ? _value.memberEmail
          : memberEmail // ignore: cast_nullable_to_non_nullable
              as String,
      memberType: null == memberType
          ? _value.memberType
          : memberType // ignore: cast_nullable_to_non_nullable
              as String,
      registerDate: null == registerDate
          ? _value.registerDate
          : registerDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expireDate: null == expireDate
          ? _value.expireDate
          : expireDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      instName: null == instName
          ? _value.instName
          : instName // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DataImplCopyWith<$Res> implements $DataCopyWith<$Res> {
  factory _$$DataImplCopyWith(
          _$DataImpl value, $Res Function(_$DataImpl) then) =
      __$$DataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String token,
      @JsonKey(name: 'member_id') String memberId,
      @JsonKey(name: 'member_name') String memberName,
      @JsonKey(name: 'member_email') String memberEmail,
      @JsonKey(name: 'member_type') String memberType,
      @JsonKey(name: 'register_date') DateTime registerDate,
      @JsonKey(name: 'expire_date') DateTime expireDate,
      @JsonKey(name: 'inst_name') String instName,
      String image});
}

/// @nodoc
class __$$DataImplCopyWithImpl<$Res>
    extends _$DataCopyWithImpl<$Res, _$DataImpl>
    implements _$$DataImplCopyWith<$Res> {
  __$$DataImplCopyWithImpl(_$DataImpl _value, $Res Function(_$DataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? memberId = null,
    Object? memberName = null,
    Object? memberEmail = null,
    Object? memberType = null,
    Object? registerDate = null,
    Object? expireDate = null,
    Object? instName = null,
    Object? image = null,
  }) {
    return _then(_$DataImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      memberName: null == memberName
          ? _value.memberName
          : memberName // ignore: cast_nullable_to_non_nullable
              as String,
      memberEmail: null == memberEmail
          ? _value.memberEmail
          : memberEmail // ignore: cast_nullable_to_non_nullable
              as String,
      memberType: null == memberType
          ? _value.memberType
          : memberType // ignore: cast_nullable_to_non_nullable
              as String,
      registerDate: null == registerDate
          ? _value.registerDate
          : registerDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expireDate: null == expireDate
          ? _value.expireDate
          : expireDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      instName: null == instName
          ? _value.instName
          : instName // ignore: cast_nullable_to_non_nullable
              as String,
      image: null == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DataImpl implements _Data {
  const _$DataImpl(
      {required this.token,
      @JsonKey(name: 'member_id') required this.memberId,
      @JsonKey(name: 'member_name') required this.memberName,
      @JsonKey(name: 'member_email') required this.memberEmail,
      @JsonKey(name: 'member_type') required this.memberType,
      @JsonKey(name: 'register_date') required this.registerDate,
      @JsonKey(name: 'expire_date') required this.expireDate,
      @JsonKey(name: 'inst_name') required this.instName,
      required this.image});

  factory _$DataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataImplFromJson(json);

  @override
  final String token;
  @override
  @JsonKey(name: 'member_id')
  final String memberId;
  @override
  @JsonKey(name: 'member_name')
  final String memberName;
  @override
  @JsonKey(name: 'member_email')
  final String memberEmail;
  @override
  @JsonKey(name: 'member_type')
  final String memberType;
  @override
  @JsonKey(name: 'register_date')
  final DateTime registerDate;
  @override
  @JsonKey(name: 'expire_date')
  final DateTime expireDate;
  @override
  @JsonKey(name: 'inst_name')
  final String instName;
  @override
  final String image;

  @override
  String toString() {
    return 'Data(token: $token, memberId: $memberId, memberName: $memberName, memberEmail: $memberEmail, memberType: $memberType, registerDate: $registerDate, expireDate: $expireDate, instName: $instName, image: $image)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.memberName, memberName) ||
                other.memberName == memberName) &&
            (identical(other.memberEmail, memberEmail) ||
                other.memberEmail == memberEmail) &&
            (identical(other.memberType, memberType) ||
                other.memberType == memberType) &&
            (identical(other.registerDate, registerDate) ||
                other.registerDate == registerDate) &&
            (identical(other.expireDate, expireDate) ||
                other.expireDate == expireDate) &&
            (identical(other.instName, instName) ||
                other.instName == instName) &&
            (identical(other.image, image) || other.image == image));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, token, memberId, memberName,
      memberEmail, memberType, registerDate, expireDate, instName, image);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DataImplCopyWith<_$DataImpl> get copyWith =>
      __$$DataImplCopyWithImpl<_$DataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DataImplToJson(
      this,
    );
  }
}

abstract class _Data implements Data {
  const factory _Data(
      {required final String token,
      @JsonKey(name: 'member_id') required final String memberId,
      @JsonKey(name: 'member_name') required final String memberName,
      @JsonKey(name: 'member_email') required final String memberEmail,
      @JsonKey(name: 'member_type') required final String memberType,
      @JsonKey(name: 'register_date') required final DateTime registerDate,
      @JsonKey(name: 'expire_date') required final DateTime expireDate,
      @JsonKey(name: 'inst_name') required final String instName,
      required final String image}) = _$DataImpl;

  factory _Data.fromJson(Map<String, dynamic> json) = _$DataImpl.fromJson;

  @override
  String get token;
  @override
  @JsonKey(name: 'member_id')
  String get memberId;
  @override
  @JsonKey(name: 'member_name')
  String get memberName;
  @override
  @JsonKey(name: 'member_email')
  String get memberEmail;
  @override
  @JsonKey(name: 'member_type')
  String get memberType;
  @override
  @JsonKey(name: 'register_date')
  DateTime get registerDate;
  @override
  @JsonKey(name: 'expire_date')
  DateTime get expireDate;
  @override
  @JsonKey(name: 'inst_name')
  String get instName;
  @override
  String get image;
  @override
  @JsonKey(ignore: true)
  _$$DataImplCopyWith<_$DataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
