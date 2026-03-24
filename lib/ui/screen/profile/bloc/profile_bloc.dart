import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/data/datasource/remote/song_remote_data_source.dart';
import 'package:login_flutter/domain/usecases/get_profile_usecase.dart';
import 'package:login_flutter/domain/usecases/update_avatar_usecase.dart';
import 'package:login_flutter/domain/usecases/update_profile_usecase.dart';
import 'package:login_flutter/ui/screen/profile/bloc/profile_event.dart';
import 'package:login_flutter/ui/screen/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateAvatarUseCase updateAvatarUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  
  // Reuse SongRemoteDataSource just for Cloudinary upload to keep it simple
  final SongRemoteDataSource remoteDataSource = SongRemoteDataSource();

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateAvatarUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await getProfileUseCase();
        emit(ProfileLoaded(profile: profile));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });

    on<UpdateAvatarEvent>((event, emit) async {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(ProfileLoading()); // Show loading while uploading image
        try {
          // 1. Upload image to Cloudinary
          final imageUrl = await remoteDataSource.uploadImage(XFile(event.imagePath));
          
          // 2. Lưu vào Firestore
          await updateAvatarUseCase(imageUrl);
          
          // 3. Update profile entity hiển thị giao diện
          final updatedProfile = currentState.profile.copyWith(avatarUrl: imageUrl);
          
          emit(ProfileLoaded(profile: updatedProfile));
        } catch (e) {
          emit(ProfileError(message: e.toString()));
          // nếu lỗi, hiển thị lại profile cũ
          emit(ProfileLoaded(profile: currentState.profile));
        }
      }
    });

    on<UpdateProfileInfoEvent>((event, emit) async {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(ProfileLoading());
        try {
          await updateProfileUseCase(event.username);
          final updatedProfile = currentState.profile.copyWith(username: event.username);
          emit(ProfileLoaded(profile: updatedProfile));
        } catch (e) {
          emit(ProfileError(message: e.toString()));
          emit(ProfileLoaded(profile: currentState.profile));
        }
      }
    });
  }
}
