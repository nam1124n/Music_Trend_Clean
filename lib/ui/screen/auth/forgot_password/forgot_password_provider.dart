import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/data/datasource/remote/auth_remote_data_source.dart';
import 'package:login_flutter/data/repositories/auth_repository_impl.dart';
import 'package:login_flutter/domain/repositories/auth_repository.dart';
import 'package:login_flutter/domain/usecases/reset_password_usecase.dart';
import 'package:login_flutter/ui/screen/auth/forgot_password/forgot_password_notifier.dart';
import 'package:login_flutter/ui/screen/auth/forgot_password/forgot_password_state.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.read(authRepositoryProvider));
});

final forgotPasswordNotifierProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
      return ForgotPasswordNotifier(ref.read(resetPasswordUseCaseProvider));
    });
