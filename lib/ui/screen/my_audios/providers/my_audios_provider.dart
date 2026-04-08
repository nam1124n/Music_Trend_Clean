import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_flutter/domain/entities/generated_audio_entity.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_provider.dart';
import 'package:login_flutter/ui/screen/auth/providers/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final myAudiosProvider =
    StateNotifierProvider<MyAudiosNotifier, List<GeneratedAudioEntity>>((ref) {
      final authState = ref.watch(authNotifierProvider);
      final userId = authState is AuthSuccess ? authState.user.id : 'guest';
      return MyAudiosNotifier(userId);
    });

class MyAudiosNotifier extends StateNotifier<List<GeneratedAudioEntity>> {
  final String userId;

  MyAudiosNotifier(this.userId) : super([]) {
    _loadAudios();
  }

  String get _key => 'my_created_audios_$userId';

  Future<void> _loadAudios() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList != null && jsonList.isNotEmpty) {
      try {
        final loaded = jsonList
            .map((str) => GeneratedAudioEntity.fromJson(jsonDecode(str)))
            .toList();
        state = loaded;
      } catch (_) {}
    }
  }

  Future<void> _saveAudios(List<GeneratedAudioEntity> audios) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = audios.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  void addAudio(GeneratedAudioEntity audio) {
    state = [audio, ...state];
    _saveAudios(state);
  }

  void removeAudio(String id) {
    state = state.where((audio) => audio.id != id).toList();
    _saveAudios(state);
  }
}
