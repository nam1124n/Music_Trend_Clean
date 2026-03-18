import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends AuthEvent{
  final String email;
  final String password;

  const LoginButtonPressed({required this.email, required this.password});

  @override
  List<Object> get props => [email,password];
  }
class SignUpButtonPressed extends AuthEvent{

  final String fullName;
  final String email;
  final String password;
  const SignUpButtonPressed({
    required this.fullName,
    required this.email,
    required this.password,
  });
  @override
  List<Object> get props => [fullName, email, password];
}