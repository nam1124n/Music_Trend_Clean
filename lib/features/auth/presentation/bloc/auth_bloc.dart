import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
  }) : super(AuthInitial()) {
    
    // Đăng ký cho sự kiện LoginButtonPressed
    on<LoginButtonPressed>((event, emit) async {
      // 1. Vừa bấm nút xong thì bảo UI xoay vòng loading đi
      emit(AuthLoading());
      
      try {
        // 2. Sai UseCase đi xuống Model -> Gọi API (Chờ đợi)
        final user = await loginUseCase(event.email, event.password);
        
        // 3. Báo Thành công, quăng dữ liệu User ra
        emit(AuthSuccess(user));
      } catch (e) {
        // 4. Báo Thất bại, quăng text lỗi ra
        emit(AuthFailure(e.toString()));
      }
    });

    // Đăng ký cho sự kiện SignUpButtonPressed
    on<SignUpButtonPressed>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signUpUseCase(event.fullName, event.email, event.password);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
