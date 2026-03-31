import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_provider.dart';
import 'package:login_flutter/ui/screen/audio/providers/audio_player_provider.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_provider.dart';
import 'package:login_flutter/ui/screen/auth/login_screen.dart';
import 'package:login_flutter/ui/screen/discover/providers/favorites_provider.dart';
import 'package:login_flutter/ui/screen/discover/providers/recents_provider.dart';
import 'package:login_flutter/ui/screen/profile/providers/profile_provider.dart';
import 'package:login_flutter/ui/screen/search/providers/search_provider.dart';

class ProfileHeader extends ConsumerWidget {
  final Color textPrimary;

  const ProfileHeader({super.key, required this.textPrimary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _HeaderIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          textPrimary: textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: Text(
            'Profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        PopupMenuButton<String>(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          offset: const Offset(0, 46),
          onSelected: (value) async {
            if (value == 'logout') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text('Bạn có muốn đăng xuất không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        child: const Text(
                          'Không',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Có'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true && context.mounted) {
                ref.invalidate(audioPlayerNotifierProvider);
                ref.invalidate(favoriteNotifierProvider);
                ref.invalidate(recentNotifierProvider);
                ref.invalidate(searchNotifierProvider);
                ref.invalidate(songNotifierProvider);
                ref.invalidate(profileNotifierProvider);
                ref.invalidate(authNotifierProvider);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: _HeaderIconButton(
            icon: Icons.settings_rounded,
            textPrimary: textPrimary,
            onPressed: null,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    this.onPressed,
    required this.textPrimary,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: textPrimary),
        ),
      ),
    );
  }
}
