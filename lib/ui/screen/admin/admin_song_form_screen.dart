import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_flutter/app/utils/audio_file_picker.dart';
import 'package:login_flutter/domain/entities/song_entity.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_provider.dart';
import 'package:login_flutter/ui/screen/admin/providers/song_state.dart';
import 'package:login_flutter/ui/screen/admin/widgets/label_text.dart';

class AdminSongFormScreen extends ConsumerStatefulWidget {
  const AdminSongFormScreen({super.key});

  @override
  ConsumerState<AdminSongFormScreen> createState() =>
      _AdminSongFormScreenState();
}

class _AdminSongFormScreenState extends ConsumerState<AdminSongFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  XFile? _pickedAudio;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _pickedImage = file;
      _pickedImageBytes = bytes;
    });
  }

  Future<void> _pickAudio() async {
    final file = await pickAudioFile();
    if (file == null || !mounted) return;
    setState(() => _pickedAudio = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh bìa!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_pickedAudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn file audio!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final song = SongEntity(
      id: '',
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      audioUrl: '',
      imageUrl: '',
    );

    await ref
        .read(songNotifierProvider.notifier)
        .addSong(song, _pickedImage!, _pickedAudio!);

    if (!mounted) {
      return;
    }

    final state = ref.read(songNotifierProvider);
    if (state is SongActionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thao tác thành công!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      ref.read(songNotifierProvider.notifier).loadSongs();
      Navigator.pop(context);
    } else if (state is SongError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${state.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(songNotifierProvider);
    final isLoading = state is SongLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Thêm bài hát mới',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8C52FF),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LabelText('Ảnh bìa'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isLoading ? null : _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _pickedImage != null
                          ? const Color(0xFF8C52FF)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: _pickedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(
                            _pickedImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chọn ảnh bìa',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const LabelText('File Audio (mp3, m4a...)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isLoading ? null : _pickAudio,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _pickedAudio != null
                          ? const Color(0xFF8C52FF)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _pickedAudio != null
                            ? Icons.audio_file
                            : Icons.upload_file,
                        color: _pickedAudio != null
                            ? const Color(0xFF8C52FF)
                            : Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _pickedAudio != null
                              ? _pickedAudio!.name
                              : 'Nhấn để chọn file âm thanh',
                          style: TextStyle(
                            color: _pickedAudio != null
                                ? Colors.black87
                                : Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const LabelText('Tên bài hát'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                enabled: !isLoading,
                decoration: _inputDeco('Ví dụ: Hoa Nở Không Màu'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Vui lòng nhập tên bài hát'
                    : null,
              ),
              const SizedBox(height: 20),
              const LabelText('Tên nghệ sĩ'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _artistController,
                enabled: !isLoading,
                decoration: _inputDeco('Ví dụ: Hoài Lâm'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Vui lòng nhập tên nghệ sĩ'
                    : null,
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C52FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Đang upload lên Cloudinary...'),
                          ],
                        )
                      : const Text(
                          'Upload & Lưu bài hát',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400]),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: Color(0xFF8C52FF), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
}
