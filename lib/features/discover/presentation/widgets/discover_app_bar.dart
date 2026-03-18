import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:login_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:login_flutter/features/auth/presentation/bloc/auth_state.dart';

class DiscoverAppBar extends StatelessWidget {
  const DiscoverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Logo
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE8DEFF),
                ),
                child: const Center(
                  child: Icon(
                    Icons.graphic_eq,
                    color: Color(0xFF8C52FF),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                "Khám phá Âm nhạc",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // ── Nút Admin (Chỉ hiển thị cho admin@gmail.com) ──
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthSuccess && state.user.email == 'admin@gmail.com') {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8C52FF),
                          border: Border.all(color: Colors.transparent),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                   if (state is AuthSuccess && state.user.email == 'admin@gmail.com') {
                     return const SizedBox(width: 8);
                   }
                   return const SizedBox.shrink();
                },
              ),
              // Notification Bell
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // Light grey
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm bài hát, nghệ sĩ hoặc album",
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
