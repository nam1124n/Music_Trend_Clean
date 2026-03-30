import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/ui/screen/auth/forgot_password/forgot_password_provider.dart';
import 'package:login_flutter/ui/screen/auth/forgot_password/forgot_password_state.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ForgotPasswordState>(forgotPasswordNotifierProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(forgotPasswordNotifierProvider.notifier).clearMessage();
      }

      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(forgotPasswordNotifierProvider.notifier).clearMessage();
      }
    });

    final state = ref.watch(forgotPasswordNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: ref
                  .read(forgotPasswordNotifierProvider.notifier)
                  .onEmailChanged,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@example.com',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.status == ForgotPasswordStatus.loading
                  ? null
                  : () {
                      ref
                          .read(forgotPasswordNotifierProvider.notifier)
                          .submit();
                    },
              child: state.status == ForgotPasswordStatus.loading
                  ? const CircularProgressIndicator()
                  : const Text('Gửi email đặt lại mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}
