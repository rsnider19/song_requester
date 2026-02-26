// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  isAnonymous: json['is_anonymous'] as bool,
  isPerformer: json['is_performer'] as bool,
  email: json['email'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_anonymous': instance.isAnonymous,
      'is_performer': instance.isPerformer,
      'email': ?instance.email,
    };
