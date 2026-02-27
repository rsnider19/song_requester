// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'performer_song.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PerformerSong {

 String get performerSongId; String get profileId; String get songId; int get sortOrder; Song get song;
/// Create a copy of PerformerSong
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PerformerSongCopyWith<PerformerSong> get copyWith => _$PerformerSongCopyWithImpl<PerformerSong>(this as PerformerSong, _$identity);

  /// Serializes this PerformerSong to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PerformerSong&&(identical(other.performerSongId, performerSongId) || other.performerSongId == performerSongId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.songId, songId) || other.songId == songId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.song, song) || other.song == song));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,performerSongId,profileId,songId,sortOrder,song);

@override
String toString() {
  return 'PerformerSong(performerSongId: $performerSongId, profileId: $profileId, songId: $songId, sortOrder: $sortOrder, song: $song)';
}


}

/// @nodoc
abstract mixin class $PerformerSongCopyWith<$Res>  {
  factory $PerformerSongCopyWith(PerformerSong value, $Res Function(PerformerSong) _then) = _$PerformerSongCopyWithImpl;
@useResult
$Res call({
 String performerSongId, String profileId, String songId, int sortOrder, Song song
});


$SongCopyWith<$Res> get song;

}
/// @nodoc
class _$PerformerSongCopyWithImpl<$Res>
    implements $PerformerSongCopyWith<$Res> {
  _$PerformerSongCopyWithImpl(this._self, this._then);

  final PerformerSong _self;
  final $Res Function(PerformerSong) _then;

/// Create a copy of PerformerSong
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? performerSongId = null,Object? profileId = null,Object? songId = null,Object? sortOrder = null,Object? song = null,}) {
  return _then(_self.copyWith(
performerSongId: null == performerSongId ? _self.performerSongId : performerSongId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,song: null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as Song,
  ));
}
/// Create a copy of PerformerSong
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res> get song {
  
  return $SongCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}


/// Adds pattern-matching-related methods to [PerformerSong].
extension PerformerSongPatterns on PerformerSong {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PerformerSong value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PerformerSong() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PerformerSong value)  $default,){
final _that = this;
switch (_that) {
case _PerformerSong():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PerformerSong value)?  $default,){
final _that = this;
switch (_that) {
case _PerformerSong() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String performerSongId,  String profileId,  String songId,  int sortOrder,  Song song)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PerformerSong() when $default != null:
return $default(_that.performerSongId,_that.profileId,_that.songId,_that.sortOrder,_that.song);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String performerSongId,  String profileId,  String songId,  int sortOrder,  Song song)  $default,) {final _that = this;
switch (_that) {
case _PerformerSong():
return $default(_that.performerSongId,_that.profileId,_that.songId,_that.sortOrder,_that.song);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String performerSongId,  String profileId,  String songId,  int sortOrder,  Song song)?  $default,) {final _that = this;
switch (_that) {
case _PerformerSong() when $default != null:
return $default(_that.performerSongId,_that.profileId,_that.songId,_that.sortOrder,_that.song);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PerformerSong implements PerformerSong {
  const _PerformerSong({required this.performerSongId, required this.profileId, required this.songId, required this.sortOrder, required this.song});
  factory _PerformerSong.fromJson(Map<String, dynamic> json) => _$PerformerSongFromJson(json);

@override final  String performerSongId;
@override final  String profileId;
@override final  String songId;
@override final  int sortOrder;
@override final  Song song;

/// Create a copy of PerformerSong
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PerformerSongCopyWith<_PerformerSong> get copyWith => __$PerformerSongCopyWithImpl<_PerformerSong>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PerformerSongToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PerformerSong&&(identical(other.performerSongId, performerSongId) || other.performerSongId == performerSongId)&&(identical(other.profileId, profileId) || other.profileId == profileId)&&(identical(other.songId, songId) || other.songId == songId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.song, song) || other.song == song));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,performerSongId,profileId,songId,sortOrder,song);

@override
String toString() {
  return 'PerformerSong(performerSongId: $performerSongId, profileId: $profileId, songId: $songId, sortOrder: $sortOrder, song: $song)';
}


}

/// @nodoc
abstract mixin class _$PerformerSongCopyWith<$Res> implements $PerformerSongCopyWith<$Res> {
  factory _$PerformerSongCopyWith(_PerformerSong value, $Res Function(_PerformerSong) _then) = __$PerformerSongCopyWithImpl;
@override @useResult
$Res call({
 String performerSongId, String profileId, String songId, int sortOrder, Song song
});


@override $SongCopyWith<$Res> get song;

}
/// @nodoc
class __$PerformerSongCopyWithImpl<$Res>
    implements _$PerformerSongCopyWith<$Res> {
  __$PerformerSongCopyWithImpl(this._self, this._then);

  final _PerformerSong _self;
  final $Res Function(_PerformerSong) _then;

/// Create a copy of PerformerSong
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? performerSongId = null,Object? profileId = null,Object? songId = null,Object? sortOrder = null,Object? song = null,}) {
  return _then(_PerformerSong(
performerSongId: null == performerSongId ? _self.performerSongId : performerSongId // ignore: cast_nullable_to_non_nullable
as String,profileId: null == profileId ? _self.profileId : profileId // ignore: cast_nullable_to_non_nullable
as String,songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,song: null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as Song,
  ));
}

/// Create a copy of PerformerSong
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongCopyWith<$Res> get song {
  
  return $SongCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}

// dart format on
