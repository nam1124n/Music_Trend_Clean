import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/domain/usecases/get_profile_usecase.dart';
import 'package:login_flutter/ui/screen/profile/bloc/profile_event.dart';
import 'package:login_flutter/ui/screen/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;

  ProfileBloc({required this.getProfileUseCase}) : super(ProfileInitial()) {
    on<FetchProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await getProfileUseCase();
        emit(ProfileLoaded(profile: profile));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}
