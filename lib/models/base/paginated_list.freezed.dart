// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PaginatedList<T> _$PaginatedListFromJson<T>(
    Map<String, dynamic> json, T Function(Object?) fromJsonT) {
  return _PaginatedList<T>.fromJson(json, fromJsonT);
}

/// @nodoc
mixin _$PaginatedList<T> {
  List<T> get items => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  int? get totalItems => throw _privateConstructorUsedError;
  bool get isLastPage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PaginatedListCopyWith<T, PaginatedList<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedListCopyWith<T, $Res> {
  factory $PaginatedListCopyWith(
          PaginatedList<T> value, $Res Function(PaginatedList<T>) then) =
      _$PaginatedListCopyWithImpl<T, $Res, PaginatedList<T>>;
  @useResult
  $Res call(
      {List<T> items,
      int currentPage,
      int pageSize,
      int? totalItems,
      bool isLastPage});
}

/// @nodoc
class _$PaginatedListCopyWithImpl<T, $Res, $Val extends PaginatedList<T>>
    implements $PaginatedListCopyWith<T, $Res> {
  _$PaginatedListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? totalItems = freezed,
    Object? isLastPage = null,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<T>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalItems: freezed == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int?,
      isLastPage: null == isLastPage
          ? _value.isLastPage
          : isLastPage // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PaginatedListImplCopyWith<T, $Res>
    implements $PaginatedListCopyWith<T, $Res> {
  factory _$$PaginatedListImplCopyWith(_$PaginatedListImpl<T> value,
          $Res Function(_$PaginatedListImpl<T>) then) =
      __$$PaginatedListImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {List<T> items,
      int currentPage,
      int pageSize,
      int? totalItems,
      bool isLastPage});
}

/// @nodoc
class __$$PaginatedListImplCopyWithImpl<T, $Res>
    extends _$PaginatedListCopyWithImpl<T, $Res, _$PaginatedListImpl<T>>
    implements _$$PaginatedListImplCopyWith<T, $Res> {
  __$$PaginatedListImplCopyWithImpl(_$PaginatedListImpl<T> _value,
      $Res Function(_$PaginatedListImpl<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? totalItems = freezed,
    Object? isLastPage = null,
  }) {
    return _then(_$PaginatedListImpl<T>(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<T>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalItems: freezed == totalItems
          ? _value.totalItems
          : totalItems // ignore: cast_nullable_to_non_nullable
              as int?,
      isLastPage: null == isLastPage
          ? _value.isLastPage
          : isLastPage // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable(genericArgumentFactories: true)
class _$PaginatedListImpl<T> extends _PaginatedList<T> {
  const _$PaginatedListImpl(
      {required final List<T> items,
      required this.currentPage,
      required this.pageSize,
      this.totalItems,
      this.isLastPage = false})
      : _items = items,
        super._();

  factory _$PaginatedListImpl.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$$PaginatedListImplFromJson(json, fromJsonT);

  final List<T> _items;
  @override
  List<T> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int currentPage;
  @override
  final int pageSize;
  @override
  final int? totalItems;
  @override
  @JsonKey()
  final bool isLastPage;

  @override
  String toString() {
    return 'PaginatedList<$T>(items: $items, currentPage: $currentPage, pageSize: $pageSize, totalItems: $totalItems, isLastPage: $isLastPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedListImpl<T> &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.totalItems, totalItems) ||
                other.totalItems == totalItems) &&
            (identical(other.isLastPage, isLastPage) ||
                other.isLastPage == isLastPage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      currentPage,
      pageSize,
      totalItems,
      isLastPage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedListImplCopyWith<T, _$PaginatedListImpl<T>> get copyWith =>
      __$$PaginatedListImplCopyWithImpl<T, _$PaginatedListImpl<T>>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return _$$PaginatedListImplToJson<T>(this, toJsonT);
  }
}

abstract class _PaginatedList<T> extends PaginatedList<T> {
  const factory _PaginatedList(
      {required final List<T> items,
      required final int currentPage,
      required final int pageSize,
      final int? totalItems,
      final bool isLastPage}) = _$PaginatedListImpl<T>;
  const _PaginatedList._() : super._();

  factory _PaginatedList.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =
      _$PaginatedListImpl<T>.fromJson;

  @override
  List<T> get items;
  @override
  int get currentPage;
  @override
  int get pageSize;
  @override
  int? get totalItems;
  @override
  bool get isLastPage;
  @override
  @JsonKey(ignore: true)
  _$$PaginatedListImplCopyWith<T, _$PaginatedListImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
