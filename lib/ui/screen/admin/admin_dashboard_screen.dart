import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/ui/screen/admin/admin_song_form_screen.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_provider.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_state.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_provider.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_state.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songState = ref.watch(songNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Admin Panel — Quản lý bài hát',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8C52FF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.read(songNotifierProvider.notifier).loadSongs(),
          ),
        ],
      ),
      body: _buildBody(context, ref, authState, songState),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8C52FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm bài hát'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminSongFormScreen()),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    SongState songState,
  ) {
    if (authState is! AuthSuccess ||
        authState.user.email != 'admin@gmail.com') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Truy cập bị từ chối',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Bạn không có quyền truy cập vào trang này.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      );
    }

    if (songState is SongLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8C52FF)),
      );
    }

    if (songState is SongError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(songState.message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(songNotifierProvider.notifier).loadSongs(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (songState is SongLoaded) {
      if (songState.songs.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: songState.songs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final song = songState.songs[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: song.imageUrl.isNotEmpty
                    ? Image.network(
                        song.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholderIcon(),
                      )
                    : _placeholderIcon(),
              ),
              title: Text(
                song.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                song.artist,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () =>
                    _confirmDelete(context, ref, song.id, song.title),
              ),
            ),
          );
        },
      );
    }

    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF8C52FF)),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.music_note, color: Color(0xFF8C52FF), size: 28),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF3E8FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.library_music_outlined,
              size: 64,
              color: Color(0xFF8C52FF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có bài hát nào',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn + để thêm bài hát đầu tiên',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xoá'),
        content: Text('Bạn có chắc muốn xoá "$title" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Huỷ', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(songNotifierProvider.notifier).deleteSong(id);

              if (!context.mounted) {
                return;
              }

              final songState = ref.read(songNotifierProvider);
              if (songState is SongActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thao tác thành công!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                ref.read(songNotifierProvider.notifier).loadSongs();
              } else if (songState is SongError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: ${songState.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
