// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spotify_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpotifySearchResult {

 String get spotifyTrackId; String get title; String get artist; String get artistId; String? get albumArtUrl;
/// Create a copy of SpotifySearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpotifySearchResultCopyWith<SpotifySearchResult> get copyWith => _$SpotifySearchResultCopyWithImpl<SpotifySearchResult>(this as SpotifySearchResult, _$identity);

  /// Serializes this SpotifySearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpotifySearchResult&&(identical(other.spotifyTrackId, spotifyTrackId) || other.spotifyTrackId == spotifyTrackId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.artistId, artistId) || other.artistId == artistId)&&(identical(other.albumArtUrl, albumArtUrl) || other.albumArtUrl == albumArtUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,spotifyTrackId,title,artist,artistId,albumArtUrl);

@override
String toString() {
  return 'SpotifySearchResult(spotifyTrackId: $spotifyTrackId, title: $title, artist: $artist, artistId: $artistId, albumArtUrl: $albumArtUrl)';
}


}

/// @nodoc
abstract mixin class $SpotifySearchResultCopyWith<$Res>  {
  factory $SpotifySearchResultCopyWith(SpotifySearchResult value, $Res Function(SpotifySearchResult) _then) = _$SpotifySearchResultCopyWithImpl;
@useResult
$Res call({
 String spotifyTrackId, String title, String artist, String artistId, String? albumArtUrl
});




}
/// @nodoc
class _$SpotifySearchResultCopyWithImpl<$Res>
    implements $SpotifySearchResultCopyWith<$Res> {
  _$SpotifySearchResultCopyWithImpl(this._self, this._then);

  final SpotifySearchResult _self;
  final $Res Function(SpotifySearchResult) _then;

/// Create a copy of SpotifySearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? spotifyTrackId = null,Object? title = null,Object? artist = null,Object? artistId = null,Object? albumArtUrl = freezed,}) {
  return _then(_self.copyWith(
spotifyTrackId: null == spotifyTrackId ? _self.spotifyTrackId : spotifyTrackId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,artistId: null == artistId ? _self.artistId : artistId // ignore: cast_nullable_to_non_nullable
as String,albumArtUrl: freezed == albumArtUrl ? _self.albumArtUrl : albumArtUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SpotifySearchResult].
extension SpotifySearchResultPatterns on SpotifySearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpotifySearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpotifySearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpotifySearchResult value)  $default,){
final _that = this;
switch (_that) {
case _SpotifySearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpotifySearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _SpotifySearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String spotifyTrackId,  String title,  String artist,  String artistId,  String? albumArtUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpotifySearchResult() when $default != null:
return $default(_that.spotifyTrackId,_that.title,_that.artist,_that.artistId,_that.albumArtUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String spotifyTrackId,  String title,  String artist,  String artistId,  String? albumArtUrl)  $default,) {final _that = this;
switch (_that) {
case _SpotifySearchResult():
return $default(_that.spotifyTrackId,_that.title,_that.artist,_that.artistId,_that.albumArtUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String spotifyTrackId,  String title,  String artist,  String artistId,  String? albumArtUrl)?  $default,) {final _that = this;
switch (_that) {
case _SpotifySearchResult() when $default != null:
return $default(_that.spotifyTrackId,_that.title,_that.artist,_that.artistId,_that.albumArtUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpotifySearchResult implements SpotifySearchResult {
  const _SpotifySearchResult({required this.spotifyTrackId, required this.title, required this.artist, required this.artistId, this.albumArtUrl});
  factory _SpotifySearchResult.fromJson(Map<String, dynamic> json) => _$SpotifySearchResultFromJson(json);

@override final  String spotifyTrackId;
@override final  String title;
@override final  String artist;
@override final  String artistId;
@override final  String? albumArtUrl;

/// Create a copy of SpotifySearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpotifySearchResultCopyWith<_SpotifySearchResult> get copyWith => __$SpotifySearchResultCopyWithImpl<_SpotifySearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpotifySearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpotifySearchResult&&(identical(other.spotifyTrackId, spotifyTrackId) || other.spotifyTrackId == spotifyTrackId)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.artistId, artistId) || other.artistId == artistId)&&(identical(other.albumArtUrl, albumArtUrl) || other.albumArtUrl == albumArtUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,spotifyTrackId,title,artist,artistId,albumArtUrl);

@override
String toString() {
  return 'SpotifySearchResult(spotifyTrackId: $spotifyTrackId, title: $title, artist: $artist, artistId: $artistId, albumArtUrl: $albumArtUrl)';
}


}

/// @nodoc
abstract mixin class _$SpotifySearchResultCopyWith<$Res> implements $SpotifySearchResultCopyWith<$Res> {
  factory _$SpotifySearchResultCopyWith(_SpotifySearchResult value, $Res Function(_SpotifySearchResult) _then) = __$SpotifySearchResultCopyWithImpl;
@override @useResult
$Res call({
 String spotifyTrackId, String title, String artist, String artistId, String? albumArtUrl
});




}
/// @nodoc
class __$SpotifySearchResultCopyWithImpl<$Res>
    implements _$SpotifySearchResultCopyWith<$Res> {
  __$SpotifySearchResultCopyWithImpl(this._self, this._then);

  final _SpotifySearchResult _self;
  final $Res Function(_SpotifySearchResult) _then;

/// Create a copy of SpotifySearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? spotifyTrackId = null,Object? title = null,Object? artist = null,Object? artistId = null,Object? albumArtUrl = freezed,}) {
  return _then(_SpotifySearchResult(
spotifyTrackId: null == spotifyTrackId ? _self.spotifyTrackId : spotifyTrackId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,artistId: null == artistId ? _self.artistId : artistId // ignore: cast_nullable_to_non_nullable
as String,albumArtUrl: freezed == albumArtUrl ? _self.albumArtUrl : albumArtUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
