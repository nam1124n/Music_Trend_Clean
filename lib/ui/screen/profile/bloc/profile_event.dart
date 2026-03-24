import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchProfileEvent extends ProfileEvent {}

class UpdateAvatarEvent extends ProfileEvent {
  final String imagePath;

  const UpdateAvatarEvent({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}
