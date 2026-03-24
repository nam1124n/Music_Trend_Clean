import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_flutter/ui/screen/admin/bloc/song_bloc.dart';
import 'package:login_flutter/ui/screen/admin/bloc/song_event.dart';
import 'package:login_flutter/ui/screen/admin/bloc/song_state.dart';
import 'package:login_flutter/ui/screen/admin/admin_song_form_screen.dart';
import 'package:login_flutter/ui/screen/auth/bloc/auth_bloc.dart';
import 'package:login_flutter/ui/screen/auth/bloc/auth_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SongBloc>().add(LoadSongsEvent());
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => context.read<SongBloc>().add(LoadSongsEvent()),
          ),
        ],
      ),
      body: BlocConsumer<SongBloc, SongState>(
        listener: (context, state) {
          if (state is SongActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thao tác thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            context.read<SongBloc>().add(LoadSongsEvent());
          } else if (state is SongError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // ── Kiểm tra quyền truy cập ──
          final authState = context.read<AuthBloc>().state;
          if (authState is! AuthSuccess || authState.user.email != 'admin@gmail.com') {
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

          if (state is SongLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8C52FF)),
            );
          }

          if (state is SongError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SongBloc>().add(LoadSongsEvent()),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is SongLoaded) {
            if (state.songs.isEmpty) return _buildEmptyState();

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.songs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final song = state.songs[index];
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
                              errorBuilder: (_, e, s) => _placeholderIcon(),
                            )
                          : _placeholderIcon(),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, song.id, song.title),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8C52FF)),
          );
        },
      ),
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
            child: const Icon(Icons.library_music_outlined, size: 64, color: Color(0xFF8C52FF)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có bài hát nào',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Nhấn + để thêm bài hát đầu tiên', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id, String title) {
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
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<SongBloc>().add(DeleteSongEvent(id));
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
